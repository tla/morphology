#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use feature 'say';
use Morph::Perseus;
use Text::Tradition::Directory;
use Devel::Peek qw/ Dump /;

binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';

# Connect to our databases
my $dir = Text::Tradition::Directory->new(
	'dsn' => 'dbi:SQLite:dbname=../stemmatology/stemmaweb/db/traditions.db' );
my $morph = Morph::Perseus->connect( 'dbi:SQLite:dbname=db/greek.db', undef, undef, 
	{ 'sqlite_unicode' => 1 } );

# Load the Tradition
my $s = $dir->new_scope();
my $tradition = $dir->lookup( '182FD018-6460-11E1-9DFE-B88D12144B1C' );
my @words;
foreach my $r ( $tradition->collation->readings ) {
	next if $r->is_meta;
	my $ws = $tradition->collation->wordsep;
	foreach my $w ( split( /\Q$ws\E/, $r->text ) ) {
		$w =~ s/^[[:punct:]]+//;
		$w =~ s/[[:punct:]]+$//;
		push( @words, $w );
	}
}

# Look up the words
my $found = scalar @words;
foreach my $w ( sort @words ) {
	my $answer = $morph->lookup( $w );
	if( @{$answer->{'objects'}} ) {
		my $matchstr = $answer->{'exact_match'} ? 'matches' : 'possible matches';
		my @matches = map { $_->token } @{$answer->{'objects'}};
		# say "Word $w has $matchstr: @matches";
	} else {
		say "Word $w not found";
		$found--;
	}
}

say STDERR "Found $found of " . @words . " words";