#!/usr/bin/env perl

use lib 'lib';
use feature 'say';
use strict;
use warnings;
use Lingua::Morph::Perseus;
use Lingua::TagSet::TreeTagger::Latin;
use Memoize;
use TryCatch;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my $morph = Lingua::Morph::Perseus->connect( @ARGV );

sub _frequent_lemma {
	my( $lem, $otherlem ) = @_;
	say STDERR "Comparing lemmas $lem and $otherlem";
	my $lemct = $morph->resultset('Lexicon')->search({ 'lemma' => $lem })->count;
	my $otherct = $morph->resultset('Lexicon')->search(
		{ 'lemma' => $otherlem })->count;
	return $lemct > $otherct ? $lem : $otherlem;
}
memoize( '_frequent_lemma' );



my $rs = $morph->resultset('Lexicon');
my %words;
while( my $row = $rs->next ) {
	my $struct;
	try {
		$struct = $row->morphology;
	} catch {
		say STDERR "Could not parse code " . $row->code;
		next;
	}
	
	my $ttag;
	try {
		$ttag = Lingua::TagSet::TreeTagger::Latin->structure2tag( $struct );
	} catch {
		say STDERR "Could not derive TreeTag from code " . $row->code;
		next;
	}
	
	my $t = $row->token;
	# say STDERR "Adding POS / lemma for $t";
	$words{$t} = {} unless exists $words{$t};
	if( exists $words{$t}->{$ttag} ) {
		# Conflicting lemma! We need to resolve it.
		my $otherlem = $words{$t}->{$ttag};
		next if _variant_lemma( $row->lemma, $otherlem );
		my $uselem = _frequent_lemma( sort( $row->lemma, $otherlem ) );
		$words{$t}->{$ttag} = $uselem;
	} else {
		$words{$t}->{$ttag} = $row->lemma;
	}
}

foreach my $w ( sort keys %words ) {
	my %lexhash = %{$words{$w}};
	my @tags = map { $_ . '  ' . $lexhash{$_} } keys %lexhash;
	say join( "\t", $w, @tags );
}

sub _variant_lemma {
	my( $lem, $otherlem ) = @_;
	$lem =~ s/\d+$//;
	$otherlem =~ s/\d+$//;
	return $lem eq $otherlem;
}
