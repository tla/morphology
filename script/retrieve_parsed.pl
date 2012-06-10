#!/usr/bin/env perl

use lib 'lib';
use feature 'say';
use strict;
use warnings;
use Lingua::TagSet::Perseus;
use Lingua::TagSet::TreeTagger::Latin;
#use Memoize;
use Text::CSV;
use TryCatch;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';
#memoize('ttpos');

# Usage: $0 TOKENS PARSES
# The arguments are the names of two files produced as follows (from an SQLite
# database):
# > .mode csv
# > .output TOKENS
# > select file, tokenid, seq, type, content from tokens order by file, seq; 
# > .output PARSES
# > select tokenid, authority, Lexicon.code from parses 
# ...> join Lexicon on parses.lex = Lexicon.lexid 
# ...> where authority not null and authority != ''; 

my $csv = Text::CSV->new( { binary => 1 } );

# First read in the parsing data
my $parses = {};
open( PARSE, $ARGV[1] ) or die "Cannot open file " . $ARGV[1];
binmode( PARSE, ':encoding(UTF-8)' );
while( my $row = $csv->getline( \*PARSE ) ) {
	my( $tokenid, $auth, $code ) = @$row;
	if( exists $parses->{$tokenid} ) {
		warn "Parse already exists for $tokenid";
	} else {
		$parses->{$tokenid} = $code;
	}
}
close PARSE;

my %quewords;
map { $quewords{$_} = 1 } qw/ absque abusque adaeque adusque aeque antique atque cumque 
	denique inique itaque namque oblique peraeque plerumque plerusque quacumque 
	qualiscumque quandocumque quandoque quantuluscumque quantumcumque quantuscumque 
	que quicumque quinque quisque quocumque quomodocumque quoque quotcumque 
	quotienscumque quotuscunque quousque susque ubicumque ubiquaque ubique undique 
	usque utcumque utercumque uterque utrimque utrobique utroque neque unusquisque /;

# Now run through the token data
my @runs;
my $curr_file = '';
my @curr_run;
my $in_run;
open( TOKENS, $ARGV[0] ) or die "Cannot open token file " . $ARGV[0];
binmode( TOKENS, ':encoding(UTF-8)' );
while( my $row = $csv->getline( \*TOKENS ) ) {
	my( $file, $tokenid, $seq, $type, $content ) = @$row;
	unless( $file eq $curr_file ) {
		# Close out the run
		push( @runs, [ @curr_run ] ) if @curr_run;
		@curr_run = ();
		$in_run = 0;
		say STDERR "Processing file $file";
		$curr_file = $file;
	}
	
	if( exists $parses->{$tokenid} ) {
		my $lexcode = $parses->{$tokenid};
		unless( $in_run ) {
			push( @runs, [ @curr_run ] ) if @curr_run;
			@curr_run = ();
			# say STDERR "Starting new run";
		}
		# Latin: break off -que suffixes
		if( $content =~ /^(.*)que$/ && !exists $quewords{lc($content)}) {
			my $base = $1;
			push( @curr_run, [ $base, ttpos( $lexcode ) ], [ 'que', 'CC' ] );
		} else {
			push( @curr_run, [ $content, ttpos( $lexcode ) ] );
		}
		$in_run = 1;
	} elsif( $type eq 'punct' && $in_run ) {
		push( @curr_run, [ $content, 'PUN' ] );
	} else {
		# If the token is not punctuation but has no parse
		## HACK for the Gallic Wars
		$in_run = 0 unless $tokenid == 175999;
	}
}
close TOKENS;
push( @runs, [ @curr_run ] ) if @curr_run;
			
# Go through each run; if it ends in a punctuation and is longer than 5
# elements, output it.
foreach my $run ( @runs ) {
	if ( @$run < 5 ) {
		# say STDERR "Skipping short run";
	} elsif( $run->[-1]->[1] ne 'PUN' ) {
		say STDERR "Skipping non-punctuated run";
	} else {
		say STDERR "Using run of length " . scalar @$run;
		map { say join( "\t", @$_ ) } @$run;
	}
}

sub ttpos {
	my $code = shift;
	my $struct = Lingua::TagSet::Perseus->tag2structure( $code );
	if( $struct ) {
		my $tag = Lingua::TagSet::TreeTagger::Latin->structure2tag( $struct );
		warn "Did not get TT tag from $code" unless $tag;
	} else {
		warn "Could not parse code $code";
		return;
	}
}
