#!/usr/bin/env perl

use strict;
use warnings;
use Test::More qw/ no_plan /;
use Lingua::Morph::Perseus;

my $morph = Lingua::Morph::Perseus->connect('Latin');
open( TF, 't/data/latintag.txt' ) or die "Could not open latintag.txt";
while(<TF>) {
	chomp;
	my( $orig, $tag, $lem ) = split( /\t/, $_ );
	my $opts = { 'ttpos' => $tag };
	unless( $lem eq '<unknown>' ) {
		$opts->{'lemma'} = [ split( /\|/, $lem ) ];
	}
	my $result = $morph->lexicon_lookup( $orig, $opts );
	ok( $result, "Got a lookup result for $orig / $tag / $lem" );
	# ok( $result->{'filtered'}, "Result was filtered" );
	foreach my $row ( @{$result->{'objects'}} ) {
		is( ref( $row->morphology ), 'Lingua::Features::Structure', 
			"Got a morphology structure for " . $row->code );
	}
}