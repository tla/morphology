use utf8;
package Lingua::Morph::Perseus;

use strict;
use warnings;
use feature 'say';
use Moose;
use Lingua::TagSet::Perseus;
use Module::Load;
use TryCatch;
use Unicode::Normalize;

our $VERSION = '1.0';

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
		my $dbdir = $INC{'Lingua/Morph/Perseus.pm'};
		$dbdir =~ s/Perseus.pm$/db/;
		@args = ( sprintf( "dbi:SQLite:dbname=%s/%s.db", 
			$dbdir, lc( $self->language ) ), undef, undef, { 'sqlite_unicode' => 1 } );
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
		#print STDERR "Setting up Latin column\n";
		my $colinfo = $self->source('Lexicon')->column_info('alt_lsj');
		my $noteinfo = $self->source('Lexicon')->column_info('note');
		$self->source('Lexicon')->remove_columns('alt_lsj', 'note');
		$self->source('Lexicon')->add_columns('alt_ls' => $colinfo, 'note' => $noteinfo );
	}
	
	# Make the connection.
	$self->$orig( @args );
};

__PACKAGE__->load_namespaces;

=head2 lexicon_lookup( $word, $opts )

Return rows from the Lexicon database for the given $word.  Substitute a Lingua::Features::Structure object for the code in the database row.

Options that can be passed in the $opts hash include:

=over 4

=item lemma - Filter results to match the supplied lemma

=item ttpos - Filter results to match the supplied TreeTagger POS

=item strict - Return an empty set if nothing matches the filters. The method will
otherwise return unfiltered results if no filter match worked.

=cut

sub lexicon_lookup {
	my( $self, $word, $opts ) = @_;
	return {} unless $word;
	$word = NFC( $word );
	# Convert to curly quotes where possible
	$word =~ s/^['\x{1fbd}]/\x{2018}/;
	$word =~ s/['\x{1fbd}]$/\x{2019}/;
	
	# If we have a TreeTagger tag, use it.
	my $ttstruct;
	if( exists $opts->{'ttpos'} ) {
		my $treetag = $opts->{'ttpos'};
		try {
			my $mod = 'Lingua::TagSet::TreeTagger::' . $self->language;
			load( $mod );
			$ttstruct = $mod->tag2structure( $treetag );
		} catch {
			warn "Could not parse passed TT tag $treetag";
		}
	}
	my $lemma = $opts->{'lemma'};

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
	
	# Filter if we were asked to
	my $filtered = '';
	if( $lemma && @$lemma ) {
		my @lfiltered = grep { _in( $_->lemma, $lemma ) } @results;
		if( $opts->{'strict'} || @lfiltered ) {
			@results = @lfiltered;
			$filtered = 'lemma';
		}
	}
	if( $ttstruct ) {
		my @tfiltered = grep { $ttstruct->is_compatible( $_->morphology ) } @results;
		if( $opts->{'strict'} || @tfiltered ) {
			@results = @tfiltered;
			$filtered .= 'ttpos';
		}
	}
	return( {
		objects     => \@results,
		exact_match => $is_exact,
		filtered    => $filtered
	} );
}

sub _in {
	my( $item, $list ) = @_;
	return grep { $_ eq $item } @$list;
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
