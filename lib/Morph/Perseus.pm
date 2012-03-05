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

sub lookup {
	my( $self, $word ) = @_;
	$word = NFC( $word );
	# Convert to curly quotes where possible
	$word =~ s/^['\x{1fbd}]/\x{2018}/;
	$word =~ s/['\x{1fbd}]$/\x{2019}/;

	my $is_exact = 1;
	my @results = $self->_straight_match( $word );
	@results = $self->_lc_match( $word ) unless @results;
	@results = $self->_name_match( $word ) unless @results;
	unless( @results ) {
		$is_exact = 0;
		@results = $self->_accentless_match( $word );
	}
	return( { 'exact_match' => $is_exact, 'objects' => \@results } );
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
				push( @matchstr, $dc ) if $dc =~ /\pL/;
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
					push( @rmatch, $dc ) if $dc =~ /\pL/;
				}
			}
			push( @resultset, $match ) if join( '', @matchstr ) eq join( '', @rmatch );
		}
	}
	return @resultset;
}

1;
