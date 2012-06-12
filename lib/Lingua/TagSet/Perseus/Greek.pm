package Lingua::TagSet::Perseus::Greek;

=head1 NAME

Lingua::TagSet::Perseus - a Lingua::Tagset parser for Perseus results

=cut

use strict;
use warnings;
use base qw/ Lingua::TagSet::Perseus /;

our @id_maps = @Lingua::TagSet::Perseus::id_maps;

# We have a different value map
my $typecodes = [
	'c' => 'rec', 
	'd' => 'dem', 
	'e' => 'proper', 
	'i' => 'int',
	'm' => 'mod', 
	'r' => 'rel', 
	's' => 'poss', 
	'k' => 'refl', 
	'x' => 'ind', 
	'p' => 'pers',
	'o' => 'co',
	'u' => 'sub',
	'a' => 'adv'
];

our %value_maps = (
	verb => [ 'c' => 'etre' ],
	noun => $typecodes,
	adj  => $typecodes,
	pron => $typecodes,
	adv  => $typecodes,
	conj => $typecodes,
	part => $typecodes,
    pers => [
    	'1' => '1', 
    	'2' => '2', 
    	'3' => '3'
    ],
    num => [
    	's' => 'sing', 'p' => 'pl', 'd' => 'dual'
    ],
	tense => [
    	'p' => 'pres', 'i' => 'imp', 'r' => 'perf', 'f' => 'fut',
		'l' => 'plup', 't' => 'fp' , 'a' => 'aor'
	],
	mode => [
		'i' => 'ind', 's' => 'subj', 'm' => 'imp', 'p' => 'part',
		'n' => 'inf', 'o' => 'opt'
	],
	voice => [
		'a' => 'act', 'm' => 'mid', 'p' => 'pass', 'd' => 'dep',
		'e' => 'mp'
	],
	gender => [
		'm' => 'masc', 'f' => 'fem', 'n' => 'neut', 'c' => 'comm'
	],
	case => [
		'a' => 'acc', 'd' => 'dat', 'g' => 'gen', 'n' => 'nom', 
		'v' => 'voc'
	],
	degree => [
		'c' => 'comp', 's' => 'sup'
	]
);

__PACKAGE__->_init();

1;