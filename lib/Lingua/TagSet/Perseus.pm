package Lingua::TagSet::Perseus;

=head1 NAME

Lingua::TagSet::Perseus - a Lingua::Tagset parser for Perseus results

=cut

use strict;
use warnings;
use base qw/ Lingua::TagSet /;
use Lingua::Features::Structure;

our @id_maps = (
	{
		features => { cat => 'verb' },
		tokens => [ 'v' ],
		submap => [
			1 => 'type',
			2 => 'pers',
			3 => 'num',
			4 => 'tense',
			5 => 'mode',
			6 => 'voice',
			7 => 'gender',
			8 => 'case',
			9 => 'degree'
		]
	},
	{
		features => { cat => 'noun' },
		tokens => [ 'n' ],
		submap => [
			1 => 'type',
			3 => 'num',
			7 => 'gender',
			8 => 'case',
			9 => 'degree'
		]
	},
	{ 
		features => { cat => 'adj', type => [ 'card', 'ord' ] },
		tokens => [ 'm', undef, undef, undef, undef, undef, undef, undef, undef, undef ],
		submap => [
			1 => 'type',
			3 => 'num',
			7 => 'gender',
			8 => 'case',
			9 => 'degree'
		]
	},
	{
		features => { cat => 'adj' },
		tokens => [ 'a' ],
		submap => [
			1 => 'type',
			3 => 'num',
			7 => 'gender',
			8 => 'case',
			9 => 'degree'
		]
	},
	{
		features => { cat => 'det' },
		tokens => [ 'p', 'a' ],
		submap => [
			3 => 'num',
			7 => 'gender',
			8 => 'case',
		]
	},
	{
		features => { cat => 'pron' },
		tokens => [ 'p' ],
		submap => [
			1 => 'type',
			3 => 'num',
			7 => 'gender',
			8 => 'case',
			9 => 'degree'
		]
	},
	{
		features => { cat => 'adv' },
		tokens => [ 'd' ],
		submap => [
			1 => 'type',
			9 => 'degree'
		]
	},
	{
		features => { cat => 'abr' },
		tokens => [ 'y' ],
	},
	{
		features => { cat => 'conj' },
		tokens => [ 'c' ],
		submap => [
			1 => 'type'
		]
	},
	{
		features => { cat => 'prep' },
		tokens => [ 'r' ],
	},
	{
		features => { cat => 'part' },
		tokens => [ 'g' ],
	},
	{
		features => { cat => 'interj' },
		tokens => [ 'i' ],
	},
	{
		features => { cat => [ 'interj' ] },
		tokens => [ 'e' ],
	},
);

# Second field is 'type' no matter the category; unify these
my $typecodes = [
	'c' => 'rec', 
	'd' => 'dem', 
	'm' => 'mod', 
	's' => 'poss', 
	'i' => 'int',
	'r' => 'rel', 
	'e' => 'proper', 
	'k' => 'refl', 
	'x' => 'ind', 
	'p' => 'pers',
	'o' => 'co',
	'u' => 'sub',
	'a' => 'adv'
];

our %value_maps = (
	verb => $typecodes,
	noun => $typecodes,
	adj  => $typecodes,
	pron => $typecodes,
	adv  => $typecodes,
	conj => $typecodes,
    pers => [
    	'1' => '1', 
    	'2' => '2', 
    	'3' => '3'
    ],
    num => [
    	's' => 'sing', 'p' => 'pl'
    ],
	tense => [
    	'p' => 'pres', 'i' => 'imp', 'r' => 'perf', 'f' => 'fut',
		'l' => 'plup', 't' => 'fp' 
	],
	mode => [
		'i' => 'ind', 's' => 'subj', 'm' => 'imp', 'p' => 'part',
		'n' => 'inf', 'g' => 'gndv', 'd' => 'gnd', 'u' => 'sup'
	],
	voice => [
		'a' => 'act', 'p' => 'pass'
	],
	gender => [
		'm' => 'masc', 'f' => 'fem', 'n' => 'neut', 'c' => 'comm'
	],
	case => [
		'a' => 'acc', 'd' => 'dat', 'g' => 'gen', 'n' => 'nom', 
		'b' => 'abl', 'v' => 'voc', 'l' => 'loc'
	],
	degree => [
		'c' => 'comp', 's' => 'sup'
	]
);

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tokens and convert special values
    my @tokens = map { $_ eq '-' ? undef : [ $_ ] } 
    	split(//, $tag_string);
    my $tag = Lingua::TagSet::Tag->new(@tokens);

    # call generic routine
    return $class->SUPER::tag2structure($tag);
}

sub structure2tag {
    my ($class, $structure) = @_;

    # call generic routine
    my $tag    = $class->SUPER::structure2tag($structure);
    my @tokens = $tag->get_tokens();

	my @tags = ( '' );
    # For each token space, push either the token or - for no token.
    # If a spot has multiple tokens, multiply the number of tags that
    # will be returned. 
    foreach my $t ( @tokens ) {
    	$t = ['-'] unless $t && @$t;
    	my @currtags;
    	foreach my $ct ( @$t ) {
    		push( @currtags, map { $_ . $ct } @tags );
    	}
    	@tags = @currtags;
    }
    
    # Make sure all the possible tags are 10 characters wide
    # and join them.
    my $tag_string = join( '|', map { sprintf( "%-10s", $_ ) } @tags );
    $tag_string =~ s/ /-/g;

    return $tag_string;
}
## TODO check esuriet -> exsurio but esurio -> esurio
## TODO check evolvo / exvolvo

1;