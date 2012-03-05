#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use feature 'say';
use Morph::Perseus;
use Unicode::Normalize;

binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';

# Connect to our databases
my $dbname = shift @ARGV;
die "Must specify a database to check" unless $dbname;
my $morph = Morph::Perseus->connect( "dbi:SQLite:dbname=$dbname", undef, undef, 
	{ 'sqlite_unicode' => 1 } );

# Get all rows in Lexicon, and see if they are all NFC
my $rs = $morph->resultset('Lexicon');
while( my $row = $rs->next ) {
	if( $row->token && $row->token ne NFC( $row->token ) ) {
		my $orig = $row->token;
		say sprintf( "Token %s in record %d is not NFC (%s), changing", 
			$orig, $row->lexid, NFC( $orig ) );
		$row->token( NFC( $orig ) );
		$row->update;
	}
	if( $row->lemma && $row->lemma ne NFC( $row->lemma ) ) {
		my $orig = $row->lemma;
		say sprintf( "Lemma %s in record %d is not NFC (%s), changing", 
			$orig, $row->lexid, NFC( $orig ) );
		$row->lemma( NFC( $orig ) );
		$row->update;
	}
}
