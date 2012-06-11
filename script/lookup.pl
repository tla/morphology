#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use feature 'say';
use Lingua::Morph::Perseus;
use Devel::Peek qw/ Dump /;

binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';

# Connect to our databases
my $lang = shift @ARGV;
my $morph = Lingua::Morph::Perseus->connect( $lang );

# Look up the word
my $found = scalar @ARGV;
foreach my $w ( @ARGV ) {
	my $answer = $morph->lexicon_lookup( $w );
	if( @{$answer->{'objects'}} ) {
		my $matchstr = $answer->{'exact_match'} ? 'matches' : 'possible matches';
		my @matches;
		foreach my $m ( @{$answer->{'objects'}} ) {
			my $morph = $m->morphology->to_string;
			push( @matches, $m->lemma . " // $morph" );
		}
		say "Word $w has $matchstr:";
		map { say "\t$_" } @matches;
	} else {
		say "Word $w not found";
		$found--;
	}
}

say STDERR "Found $found of " . @ARGV . " words";