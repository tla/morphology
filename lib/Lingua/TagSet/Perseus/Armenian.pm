package Lingua::TagSet::Perseus::Armenian;

=head1 NAME

Lingua::TagSet::Perseus::Armenian - a Lingua::Tagset parser for Perseus Armenian tags

=cut

use strict;
use warnings;
use base qw/ Lingua::TagSet /;
use Lingua::Features::Structure;

our @id_maps = (
	{
		features => { cat => 'verb' },
		tokens => [ 'verb', undef ],
		submap => [
			2 => 'pers',
			3 => 'num',
			4 => 'tense',
			5 => 'mode',
			6 => 'voice',
		]
	},
	{
		features => { cat => 'verb', mode => 'part' },
		tokens => [ 'verb', 'part' ],
		submap => [
			2 => 'case',
			3 => 'num',
		]
	},
	{
		features => { cat => 'verb', mode => 'inf' },
		tokens => [ 'verb', 'inf' ],
		submap => [
			2 => 'case',
			3 => 'num',
		]
	},
	{
		features => { cat => 'noun' },
		tokens => [ 'noun' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'noun', type => 'proper' },
		tokens => [ 'name' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'num', type => 'card' },
		tokens => [ 'numc' ],
		submap => [
			1 => 'case',
		]
	},		
	{
		features => { cat => 'num', type => 'ord' },
		tokens => [ 'numo' ],
		submap => [
			1 => 'case',
		]
	},		
	{ 
		features => { cat => 'adj' },
		tokens => [ 'adj' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{ 
		features => { cat => 'det' },
		tokens => [ 'art' ],
		submap => [
			1 => 'pers',
		]
	},	
	{
		features => { cat => 'pron', type => 'dem' },
		tokens => [ 'pdem' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'pron', type => 'id' },
		tokens => [ 'pide' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'pron', type => 'ind' },
		tokens => [ 'pind' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'pron', type => 'int' },
		tokens => [ 'prog' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'pron', type => 'pers' },
		tokens => [ 'pe' ],
		submap => [
			1 => 'pers',
			2 => 'refnum',
			3 => 'case',
		]
	},
	{
		features => { cat => 'pron', type => 'poss' },
		tokens => [ 'po' ],
		submap => [
			1 => 'pers',
			2 => 'refnum',
			3 => 'case',
			4 => 'num',
		]
	},
	{
		features => { cat => 'pron', type => 'rec' },
		tokens => [ 'prec' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'pron', type => 'ref' },
		tokens => [ 'pref' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'pron', type => 'rel' },
		tokens => [ 'prel' ],
		submap => [
			1 => 'case',
			2 => 'num',
		]
	},
	{
		features => { cat => 'adv' },
		tokens => [ 'adv' ],
	},
	{
		features => { cat => 'conj' },
		tokens => [ 'conj' ],
	},
	{
		features => { cat => 'prep' },
		tokens => [ 'prep' ],
		submap => [
			1 => 'case'
		]
	},
	{
		features => { cat => 'part' },
		tokens => [ 'nacc' ],
	}, # for nota accusativa
	{
		features => { cat => 'interj' },
		tokens => [ 'intj' ],
	},
);

# Second field is 'type' no matter the category; unify these

our %value_maps = (
    pers => [
    	'1' => '1', 
    	'2' => '2', 
    	'3' => '3'
    ],
    num => [
    	's' => 'sing', 'p' => 'pl'
    ],
    refnum => [
    	's' => 'sing', 'p' => 'pl'
    ],
	tense => [
    	'p' => 'pres', 'i' => 'imp', 'a' => 'aor'
	],
	mode => [
		'i' => 'ind', 'c' => 'subj', 'g' => 'imp'
	],
	voice => [
		'a' => 'act', 'p' => 'pass'
	],
	case => [
		'a' => 'acc', 'd' => 'dat', 'g' => 'gen', 'n' => 'nom', 
		'b' => 'abl', 'v' => 'voc', 'l' => 'loc', 'i' => 'inst'
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
    my @main = split( /\s+/, $tag_string );
    my $cat = shift @main;
    my @tokens = ( $cat );
    $DB::single = 1;
    if( $cat eq 'verb' ) {
    	# check for extra tag
    	if( $main[0] eq 'part' || $main[0] eq 'inf' ) {
    		push( @tokens, shift @main );
    	} else {
    		push( @tokens, undef );
    	}
    	push( @tokens, _parsetags( @main ) ) if @main;
    } elsif ( $cat =~ /^prep/ ) {
    	@tokens = split( /\+/, $cat );
    } elsif ( $cat =~ /^(p[eo])(.*)/ ) {
    	# Last n letters become tokens in their own right
    	@tokens = ( $1, split( '', $2 ) );
    	# Add on anything that remains. Different rules for
    	# pe and po.
    	if( $tokens[0] eq 'pe' ) {
    		push( @tokens, [ split( '', $main[0] ) ] ) if @main;
    	} else {
			push( @tokens, _parsetags( @main ) ) if @main;
		}
    } elsif ( @main == 1 ) {
    	push( @tokens, _parsetags( @main ) );
    } elsif ( @main ) {
    	warn "Cannot fully parse tag string $tag_string";
    }
	my $tag = Lingua::TagSet::Tag->new(@tokens);

    # call generic routine
    return $class->SUPER::tag2structure($tag);
}

sub structure2tag {
    my ($class, $structure) = @_;

    # call generic routine
    my $tag    = $class->SUPER::structure2tag($structure);
    my @tokens = $tag->get_tokens();
    # make sure we are dealing with arrayrefs in each case
    map { $_ = [ $_ ] unless ref( $_ ) } @tokens;

	# Put the tokens back together in our idiosyncratic way
	my @tag;
	my $cat = shift @tokens;
	if( @$cat == 1 ) {
		$cat = shift @$cat;
	} # TODO else we need multiple tags.
	
	# What we do next depends on the category.
	if( $cat eq 'verb' ) {
		push( @tag, $cat );
		my $type = shift @tokens;
		if( $type->[0] && $type->[0] =~ /^(part|inf)$/ ) {
			push( @tag, $type->[0] );
		} else {
			unshift( @tokens, $type );
		}
		if( @tokens ) {
			push( @tag, _maketags( @tokens ) );
		}	
	} elsif( $cat eq 'prep' ) {
		# Remaining token spot, if any, is case(s) that preposition governs.
		if( @tokens ) {
			my @cases = ref( $tokens[0] ) ? @{$tokens[0]} : ( $tokens[0] );
			$cat .= '+' . join( '', @cases );
		}
		push( @tag, $cat );
	} elsif( $cat eq 'pe' || $cat eq 'po' ) {
		# First two tags get added to the category
		my $origcat = $cat;
		my $pers = shift @tokens;
		my $refnum = shift @tokens;
		$cat .= $pers->[0];
		$cat .= $refnum->[0] if @$refnum;
		push( @tag, $cat );
		if( @tokens ) {
			if( $origcat eq 'pe' ) {
				# Should be one more token; concatenate it
				my @cases = @{$tokens[0]};
				push( @tag, join( '', @cases ) );
			} else {
				push( @tag, _maketags( @tokens ) );
			}
		}		
	} else {
		push( @tag, $cat );
		push( @tag, _maketags( @tokens ) ) if @tokens;
	}
	
	my $tag_string = join( ' ', @tag );
    return $tag_string;
}

sub _parsetags {
	my( $str ) = @_;
	my @fields;
	my $attrlen;
	foreach my $sort ( split( /;/, $str ) ) {
		if ( $attrlen ) {
			warn "Bad attribute tag $sort" unless length( $sort ) == $attrlen;
		} else {
			# Initialize fields according to the length of our strings.
			$attrlen = length( $sort );
			map { push( @fields, {} ) } ( 1 .. $attrlen );
		}
		my @bits = split( '', $sort );
		foreach my $i ( 0 .. $#bits ) {
			$fields[$i]->{$bits[$i]} = 1;
		}
	}
	my @tags = map { [ keys %$_ ] } @fields;
	return @tags;
}

sub _maketags {
	my( @tokens ) = @_;
	my @fields;
	foreach my $t ( @tokens ) {
		my $attr = {};
		map { $attr->{$_} = 1 if $_ } @$t;
		push( @fields, $attr );
	}
	# Combine the fields into all possibilities.
	my @tags = ( '' );
	foreach my $f ( @fields ) {
		my @bits = keys %$f;
		my @currtags = @tags;
		my @newtags;
		foreach my $b ( @bits ) {
			map { push @newtags, $_ . $b } @currtags;
		}
		@tags = @newtags;
	}
	return join( ';', @tags );
}

1;