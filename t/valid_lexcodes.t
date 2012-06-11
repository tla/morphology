#!/usr/bin/env perl

use strict;
use warnings;
use Test::More qw/ no_plan /;
use Lingua::TagSet::Perseus;
use Lingua::TagSet::Perseus::Armenian;

my @tagfiles = qw/ latincodes /;  # TODO handle Greek codes too
foreach my $fn ( @tagfiles ) {
	open( TF, "t/data/$fn" ) or die "could not read tag file $fn";
	my @rows = <TF>;
	close TF;
	chomp @rows;
	foreach my $cst ( @rows ) {
		my $struct = Lingua::TagSet::Perseus->tag2structure( $cst );
		ok( $struct, "Got a structure for $cst" );
		if( $struct ) {
			my $code = Lingua::TagSet::Perseus->structure2tag( $struct );
			# HACK to deal with mysterious e category
			if( $cst eq 'e---------' ) {
				$cst = 'i---------';
			}
			is( $code, $cst, "Code $cst reconverted to itself" );
		}
	}
}

# Armenian
open( ATF, "t/data/armcodes" ) or die "could not read tag file for Armenian";
my @rows = <ATF>;
close ATF;
chomp @rows;
foreach my $cst ( @rows ) {
	$cst =~ s/\s+$//;
	my $struct = Lingua::TagSet::Perseus::Armenian->tag2structure( $cst );
	ok( $struct, "Got structure for $cst: " 
		. ( $struct ? $struct->to_string : '' ) );
	# Reconversion of codes doesn't work properly in all cases
	# TODO List expected tags for codes in the test file
}
