package Lingua::Morph::Perseus::Structure;

=head1 NAME

Lingua::Morph::Perseus::Structure - a Lingua::Features::Structure object for Perseus results

=cut

use strict;
use warnings;
use base qw/ Lingua::Features::Structure /;
use Lingua::Features::StructureType;
use Lingua::Features::FeatureType;

### Add the feature types we need
Lingua::Features::FeatureType->_new(
    id     => 'type',
    values => {
        pers => 'personal',
        dem  => 'demonstrative',
        indef => 'indefinite',
        poss => 'possessive',
        int  => 'interrogative',
        rel  => 'relative',
        mod  => 'modal',
        proper => 'proper',
        ref  => 'reflexive',
    }
);
# pers is defined
# num is defined
Lingua::Features::FeatureType->_new(
    id     => 'tense',
    values => {
        pres => 'present',
        imp  => 'imperfect',
        fut  => 'future',
        perf => 'perfect',
        plup => 'pluperfect',
        fp   => 'future perfect',
    }
);
Lingua::Features::FeatureType->_new(
    id     => 'mode',
    values => {
        ind  => 'indicative',
        subj => 'subjunctive',
        imp  => 'imperative',
        gndv => 'gerundive',
        gnd  => 'gerund',
        sup  => 'supine',
        inf  => 'infinitive',
        part => 'participle',
    }
);
Lingua::Features::FeatureType->_new(
    id     => 'voice',
    values => {
        act  => 'active',
        pass => 'passive',
    }
);
Lingua::Features::FeatureType->_new(
    id     => 'gender',
    values => {
        masc => 'masculine',
        fem  => 'feminine',
        neut => 'neuter',
    }
);
Lingua::Features::FeatureType->_new(
    id     => 'case',
    values => {
        acc => 'accusative',
        dat => 'dative',
        gen => 'genitive',
        nom => 'nominative',
        abl => 'ablative',
        voc => 'vocative',
        loc => 'locative'
    }
);
Lingua::Features::FeatureType->_new(
    id     => 'degree',
    values => {
        comp => 'comparative',
        sup  => 'superlative',
    }
);

### Add the structure types we need
Lingua::Features::StructureType->_new(
	id		 => 'verb',
	features => [ 
		pers   => 'pers',
		num	   => 'num',
		tense  => 'tense',
		mode   => 'mode',
		voice  => 'voice',
		gender => 'gender',
		case   => 'case',
		degree => 'degree',
	]
);
Lingua::Features::StructureType->_new(
	id		 => 'noun',
	features => [ 
		type   => 'type',
		num	   => 'num',
		gender => 'gender',
		case   => 'case',
		degree => 'degree',
	]
);
Lingua::Features::StructureType->_new(
	id		 => 'adj',
	features => [ 
		type   => 'type',
		num	   => 'num',
		gender => 'gender',
		case   => 'case',
		degree => 'degree',
	]
);
Lingua::Features::StructureType->_new(
	id		 => 'pron',
	features => [ 
		type   => 'type',
		num	   => 'num',
		gender => 'gender',
		case   => 'case',
		degree => 'degree',
	]
);
Lingua::Features::StructureType->_new(
	id		 => 'det',
	features => [ 
		num	   => 'num',
		gender => 'gender',
		case   => 'case',
	]
);
Lingua::Features::StructureType->_new(
	id		 => 'adv',
	features => [ 
		type   => 'pron',
		num	   => 'num',
		gender => 'gender',
		case   => 'case',
		degree => 'degree',
	]
);
# we have cc and cs but Perseus data doesn't distinguish.
Lingua::Features::StructureType->_new(
	id		 => 'conj',
);
# preposition needs no redefinition
# interjection needs no redefinition
Lingua::Features::StructureType->_new(
	id		 => 'particle',
);


### Custom method for parsing our db tags
my %categories = (
	v => 'verb',
	n => 'noun',
	'm' => 'adj', # really 'number'
	a => 'adj',
	p => 'pron',
	d => 'adv',
	c => 'conj',
	r => 'prep',
	g => 'particle',
	i => 'interj',
	e => 'interj'
	);
my @tag_fields = (
	{ 'id' => 'type',
	  'val' => { 'd' => 'dem', 'm' => 'modal', 's' => 'poss', 'i' => 'int',
        'r' => 'rel', 'e' => 'proper', 'k' => 'ref', 'x' => 'rel', 'p' => 'pers' }
    },
	{ 'id' => 'pers',
	  'val' => { '1' => '1', '2' => '2', '3' => '3' }
    },
	{ 'id' => 'num',
	  'val' => { 's' => 'sing', 'p' => 'pl' }
    },
	{ 'id' => 'tense',
	  'val' => { 'p' => 'pres', 'i' => 'imp', 'r' => 'perf', 'f' => 'fut',
		'l' => 'plup', 't' => 'fp' }
    },
	{ 'id' => 'mode',
	  'val' => { 'i' => 'ind', 's' => 'subj', 'm' => 'imp', 'p' => 'part',
		'n' => 'inf', 'g' => 'gndv', 'd' => 'gnd', 'u' => 'sup' }
    },
	{ 'id' => 'voice',
	  'val' => { 'a' => 'act', 'p' => 'pass' }
    },
	{ 'id' => 'gender',
	  'val' => { 'm' => 'masc', 'f' => 'fem', 'n' => 'neut', 'c' => 'neut' }
    },
	{ 'id' => 'case',
	  'val' => { 'a' => 'acc', 'd' => 'dat', 'g' => 'gen', 'n' => 'nom', 
		'b' => 'abl', 'v' => 'voc', 'l' => 'loc' }
    },
	{ 'id' => 'degree',
	  'val' => { 'c' => 'comp', 's' => 'sup' }
    }
);

## TODO check gender 'c', type 'k x p', cat 'e i'
## TODO check esuriet -> exsurio but esurio -> esurio
## TODO check evolvo / exvolvo

sub from_tag {
	my( $class, $tag ) = @_;
	my @bits = split( '', $tag );
	my $cb = shift @bits; # category bit
	my %features = ( 'cat' => $categories{$cb} );
	foreach my $i ( 0 .. $#bits ) {
		next if $bits[$i] eq '-';
		my $tfs = $tag_fields[$i];
		die "No known field at index $i" unless $tfs;
		# Special case the determinative
		if( $tfs->{'id'} eq 'type' && $bits[$i] eq 'a' && $cb eq 'p' ) {
			$features{'cat'} = 'det';
		} else {
			my $fname = $tfs->{'id'};
			my $fval = exists $tfs->{'val'}->{$bits[$i]}
				? $tfs->{'val'}->{$bits[$i]} : undef;
			die "$tag: No definition for " . $bits[$i] . " for feature $fname"
				unless $fname && $fval;
			$features{$fname} = $fval;
		}
	}
	
	my $obj = $class->SUPER::new( %features );
	bless( $obj, $class );
}

1;