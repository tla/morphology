#!/usr/bin/env perl

use lib 'lib';
use feature 'say';
use strict;
use warnings;
use Lingua::TagSet::Perseus;

my $s = Lingua::TagSet::Perseus->tag2structure( @ARGV );
say $s->to_string;
say "reconverted: " . Lingua::TagSet::Perseus->structure2tag( $s );
