#!/usr/bin/env perl

use lib 'lib';
use feature 'say';
use strict;
use warnings;
use Module::Load;
use TryCatch;

my $lang = shift @ARGV;
my $tagmod = 'Lingua::TagSet::Perseus::' . ucfirst( $lang );
try {
	load $tagmod;
} catch {
	$tagmod = 'Lingua::TagSet::Perseus';
	load $tagmod;
}

my $s = $tagmod->tag2structure( @ARGV );
say $s->to_string;
say "reconverted: " . $tagmod->structure2tag( $s );

# Try the TreeTagger too
my $ttmod = 'Lingua::TagSet::TreeTagger::' . ucfirst( $lang );
try {
	load $ttmod;
} catch {
	$ttmod = undef;
}

if( $ttmod ) {
	say "treetagger: " . $ttmod->structure2tag( $s );
} else {
	say "no treetagger mod available for $lang";
}
