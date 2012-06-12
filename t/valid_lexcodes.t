#!/usr/bin/env perl

use strict;
use warnings;
use Test::More qw/ no_plan /;
use Module::Load;

my %mods = ( 'latin' => 'Lingua::TagSet::Perseus',
			'greek' => 'Lingua::TagSet::Perseus::Greek',
			'arm'   => 'Lingua::TagSet::Perseus::Armenian' );

foreach my $lang ( keys %mods ) {
	my $mod = $mods{$lang};
	my $loaded;
	eval { load( $mod ); $loaded = 1 };
	ok( $loaded, "Loaded appropriate language model for $lang" );
	if( $loaded ) {
		my $fn = "t/data/${lang}codes";
		open( TF, $fn ) or die "could not read tag file $fn";
		my @rows = <TF>;
		close TF;
		chomp @rows;
		foreach my $cst ( @rows ) {
			my $struct = $mod->tag2structure( $cst );
			ok( $struct, "Got a structure for $cst" );
			if( $struct && $lang ne 'arm' ) {
				my $code = $mod->structure2tag( $struct );
				# HACK to deal with mysterious e category
				if( $cst eq 'e---------' ) {
					$cst = 'i---------';
				}
				is( $code, $cst, "Code $cst reconverted to itself" );
			}
		}
	}
}
