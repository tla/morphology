#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use feature 'say';
use Lingua::Morph::Perseus;

binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';

# Connect to our databases
my $morph = Lingua::Morph::Perseus->connect( 'Latin' );

# Conjunction 'cum' is 'cum2' in Lewis & Short
my $cumset = $morph->resultset('Lexicon')->search(
    { lemma => 'cum' }
    );
while ( my $r = $cumset->next ) {
    if( $r->code =~ /^c/ ) {
	say sprintf( "Changing %s, code %s, to lemma cum2", 
		     $r->token, $r->code );
	$r->lemma('cum2');
	$r->update();
    }
}

# There is no 'dum2' in Lewis & Short
my $dumset = $morph->resultset('Lexicon')->search(
    { lemma => 'dum2' }
    );
while ( my $r = $dumset->next ) {
    say sprintf( "Changing %s, code %s, to lemma dum", 
		 $r->token, $r->code );
    $r->lemma('dum');
    $r->update();
}

# There is no 'licet2' in Lewis & Short
my $licset = $morph->resultset('Lexicon')->search(
    { lemma => 'licet2' }
    );
while ( my $r = $licset->next ) {
    say sprintf( "Changing %s, code %s, to lemma licet", 
		 $r->token, $r->code );
    $r->lemma('licet');
    $r->update();
}

# There is a lemma 'itaque' in Lewis & Short
my $iqset = $morph->resultset('Lexicon')->search(
    { lemma => 'ita' }
    );
while ( my $r = $iqset->next ) {
    if( $r->token =~ /q/ ) {
	say sprintf( "Changing %s, code %s, to lemma itaque", 
		     $r->token, $r->code );
	$r->lemma('itaque');
	$r->update();
    }
}


say "Done";
