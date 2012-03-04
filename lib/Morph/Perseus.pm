use utf8;
package Morph::Perseus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-03-04 21:54:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5JARAJ0Q1HF133dJ5FGPaQ

use feature 'say';
use Encode qw/ decode_utf8 /;
use Unicode::Normalize;
# TODO use Unicode::UCD qw/ charinfo /;

sub lookup {
	my( $self, $word ) = @_;
	$word = NFC( $word );

	my @results = $self->_straight_match( $word );
	@results = $self->_lc_match( $word ) unless @results;
	@results = $self->_name_match( $word ) unless @results;
	@results = $self->_quote_match( $word ) unless @results;
	@results = $self->_accentless_match( $word ) unless @results;
	return @results;
}

sub _straight_match {
	my( $self, $word ) = @_;
	my $rs = $self->resultset('Lexicon')->search({ 'token' => $word });
	return $rs->all;
}

sub _lc_match {
	my( $self, $word ) = @_;
	my $rs = $self->resultset('Lexicon')->search({ 'token' => lc($word) });
	return $rs->all;
}

sub _name_match {
	my( $self, $word ) = @_;
	my $rs = $self->resultset('Lexicon')->search({ 'token' => ucfirst($word) });
	return $rs->all;
}

sub _quote_match {
	my( $self, $word ) = @_;
	$word =~ s/^['\x{1fbd}]/\x{2018}/;
	$word =~ s/['\x{1fbd}]$/\x{2019}/;
	my $rs = $self->resultset('Lexicon')->search({ 'token' => $word });
	return $rs->all;
}

sub _accentless_match {
	my( $self, $word ) = @_;
	my @chars = split( '', $word );
	my @token;
	my @matchstr;
	foreach my $c ( @chars ) {
		if( $c eq NFD( $c ) ) {
			push( @token, $c );
			push( @matchstr, $c );
		} else {
			push( @token, '_' );
			foreach my $dc ( split( '', NFD( $c ) ) ) {
				push( @matchstr, $dc ) if $dc =~ /[[:alpha:]]/;
			}
		}
	}
	my $rs = $self->resultset('Lexicon')->search({ 
		'token' => { -like => join( '', @token ) } });
	my @resultset;
	if( $rs->count ) {
		# Return only those matches whose unaccented form matches unaccented $word
		while( my $match = $rs->next ) {
			my @rchars = split( '', NFC( $match->token ) );
			my @rmatch;
			foreach my $c ( @rchars ) {
				foreach my $dc ( split( '', NFD( $c ) ) ) {
					push( @rmatch, $dc ) if $dc =~ /[[:alpha:]]/;
				}
			}
			push( @resultset, $match ) if join( '', @matchstr ) eq join( '', @rmatch );
		}
	}
	return @resultset;
}

1;
