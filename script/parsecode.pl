#!/usr/bin/env perl

use lib 'lib';
use strict;
use warnings;
use Morph::Perseus::Structure;

my $s = Morph::Perseus::Structure->from_tag( @ARGV );
print $s->to_string;