#!/usr/bin/env perl

use strict;
use warnings;
use Test::More qw/ no_plan /;
use Lingua::TagSet::Perseus;

my @tagfiles = qw/ latincodes /;
foreach my $fn ( @tagfiles ) {
	open( TF, "t/$fn" ) or die "could not read tag file $fn";
	my @rows = <TF>;
	close TF;
	chomp @rows;
	foreach my $cst ( @rows ) {
		my $struct = Lingua::TagSet::Perseus->tag2structure( $cst );
		ok( $struct, "Got a structure for $cst" );
	}
}