use utf8;
package Morph::Perseus;

use strict;
use warnings;
use feature 'say';
use Moose;
use Morph::Perseus::Structure;
use Unicode::Normalize;

extends 'DBIx::Class::Schema';

has 'language' => (
	'is' => 'ro',
	'isa' => 'Str',
	'predicate' => 'has_language',
	'writer' => '_set_language',
	);

# Figure out which language we're using.

around connection => sub {
	my $orig = shift;
	my $self = shift;
	my @args = @_;
	
	# Are we working with defaults?
	if( @_ == 1 && $_[0] !~ /dbname/ ) {
		# Set the language
		$self->_set_language( @_ );		
		# Get the default database
		my $dbdir = $INC{'Morph/Perseus.pm'};
		$dbdir =~ s/Perseus.pm$/db/;
		@args = ( sprintf( "dbi:SQLite:dbname=%s/%s.db", 
			$dbdir, lc( $self->language ) ) );
	} else {
		# We have a database specified; make sure we have a language too.
		my $lang = delete $_[3]->{'morph_language'};
		if( $lang ) {
			$self->_set_language( $lang );
		} elsif( $_[0] =~ /greek/i ) {
			$self->_set_language('Greek');
		} elsif( $_[0] =~ /latin/i ) {
			$self->_set_language('Latin');
		}
		die "Need to specify a language somehow" unless $self->has_language;
	}
	
	# Replace the alt_lsj column with the language-appropriate one
	if( $self->language eq 'Latin' ) {
		my $colinfo = $self->source('Lexicon')->column_info('alt_lsj');
		$self->source('Lexicon')->remove_column('alt_lsj');
		$self->source('Lexicon')->add_column('alt_ls' => $colinfo );
	}
	
	# Make the connection.
	$self->$orig( @args );
};

__PACKAGE__->load_namespaces;

sub lookup {
	my( $self, $word ) = @_;
	return {} unless $word;
	$word = NFC( $word );
	# Convert to curly quotes where possible
	$word =~ s/^['\x{1fbd}]/\x{2018}/;
	$word =~ s/['\x{1fbd}]$/\x{2019}/;

	my $is_exact = 1;
	my @results = $self->_straight_match( $word );
	@results = $self->_lc_match( $word ) unless @results;
	@results = $self->_name_match( $word ) unless @results;
	my $fuzzymatch_sub = $self->language eq 'Latin' 
		? '_latinfold_match' : '_accentless_match';
	unless( @results ) {
		# Latin fuzzy matching is orthographic-only, so 
		# a hit is still an exact match.
		$is_exact = 0 unless $self->language eq 'Latin';
		@results = $self->$fuzzymatch_sub( $word );
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
	# Don't bother unless our search pattern actually changed
	return () if join( '', @token ) eq $word;
	
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

sub _latinfold_match {
	my( $self, $word ) = @_;
	my $token = _latin_sqlregex( $word );
	my $matchstr = _normalize_latin( $word );

	# Don't bother unless our search pattern actually changed
	return () if $token eq $word; 
	
	my $rs = $self->resultset('Lexicon')->search({ 'token' => { -like => $token } });
	my @resultset;
	if( $rs->count ) {
		while( my $match = $rs->next ) {
			my $rmatch = _normalize_latin( $match->token );
			next unless $rmatch eq $matchstr;
			push( @resultset, $match );
		}
	}
	return @resultset;
}

sub _normalize_latin {
	my $word = shift;
	$word = lc( $word );
	$word =~ s/cha/ca/g;
	$word =~ s/j/i/g;
	$word =~ s/v/u/g;
	return $word;
}

sub _latin_sqlregex {
	my $word = shift;
	$word = lc( $word );
	$word =~ s/c(h)?a/%a/g;
	$word =~ s/[ijuv]/_/g;
	return $word;
}

1;
