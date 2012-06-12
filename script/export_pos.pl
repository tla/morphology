#!/usr/bin/env perl

use lib 'lib';
use feature 'say';
use strict;
use warnings;
use Lingua::Morph::Perseus;
use Module::Load;
use TryCatch;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my $morph = Lingua::Morph::Perseus->connect( @ARGV );

# Export the punctuation we will need
my $punctrs = $morph->resultset('Token')->search(
	{ type => 'punct' },
	{ columns => [ 'content' ], distinct => 1 }
	);
while( my $row = $punctrs->next ) {
	my $p = $row->content;
	say STDERR "Adding punctuation $p";
	if( $p eq '.' || $p eq '!'
		|| ( $p eq '?' && $morph->language eq 'Latin' )
		|| ( $p eq ';' && $morph->language eq 'Greek' )
		|| ( $p eq "\x{589}" && $morph->language eq 'Armenian' ) ) {
		say sprintf( "%s\tSENT  %s\tPUN  %s", $p, $p, $p );
	} else {
		say "$p\tPUN  $p";
	}
}	

# Export the lexicon
my $rs = $morph->resultset('Lexicon');
my %words;
while( my $row = $rs->next ) {
	my $struct;
	try {
		$struct = $row->morphology;
		die unless $struct;
	} catch {
		say STDERR "Could not parse code " . $row->code;
		next;
	}
	
	my $ttag;
	my $mod = 'Lingua::TagSet::TreeTagger::' . $morph->language;
	try {
		load( $mod );
		$ttag = $mod->structure2tag( $struct );
		die unless $ttag;
	} catch {
		say STDERR "Could not derive TreeTag from code " . $row->code;
		next;
	}
	
	my $t = $row->token;
	say STDERR "Adding POS / lemma for $t";
	$words{$t} = {} unless exists $words{$t};
	if( exists $words{$t}->{$ttag} ) {
		# Multiple possible lemmata for this POS! Unless they are really
		# the same lemma, record all lemmata.
		my $otherlem = $words{$t}->{$ttag};
		next if _variant_lemma( $row->lemma, $otherlem );
		if( ref $otherlem ) { # Already an array, just push to it.
			push( @$otherlem, $row->lemma );
		} else {
			$words{$t}->{$ttag} = [ $otherlem, $row->lemma ];
		}
	} else {
		$words{$t}->{$ttag} = $row->lemma;
	}
}

foreach my $w ( sort keys %words ) {
	my $lexhash = $words{$w};
	my @tags;
	foreach my $ttag ( keys %$lexhash ) {
		my $lem = $lexhash->{$ttag};
		# Multiple lemmata for a given POS are joined with |
		my $lemstr = ref $lem ? join( '|', @$lem ) : $lem;
		push( @tags, "$ttag  $lemstr" );
	}
	say join( "\t", $w, @tags );
}

sub _variant_lemma {
	my( $lem, $otherlem ) = @_;
	$lem =~ s/\d+$//;
	if( ref $otherlem ) {
		foreach my $ol ( @$otherlem ) {
			$ol =~ s/\d+$//;
			return 1 if $ol eq $lem;
		}
		return 0;
	} else {
		$otherlem =~ s/\d+$//;
		return $lem eq $otherlem;
	}
}
