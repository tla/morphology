use utf8;
package Lingua::Morph::Perseus::Result::Lexicon;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Lingua::Morph::Perseus::Result::Lexicon

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Lingua::TagSet::Perseus;

=head1 TABLE: C<Lexicon>

=cut

__PACKAGE__->table("Lexicon");

=head1 ACCESSORS

=head2 lexid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 token

  data_type: 'text'
  is_nullable: 1

=head2 code

  data_type: 'text'
  is_nullable: 1

=head2 lemma

  data_type: 'text'
  is_nullable: 1

=head2 alt_lsj

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 64

=head2 note

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "lexid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "token",
  { data_type => "text", is_nullable => 1 },
  "code",
  { data_type => "text", is_nullable => 1 },
  "lemma",
  { data_type => "text", is_nullable => 1 },
  "alt_lsj",
  {
    accessor => "alt_lex",
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 64,
  },
  "note",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 20,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</lexid>

=back

=cut

__PACKAGE__->set_primary_key("lexid");


# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-03-04 21:54:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LyJ2Z14Gzc/Fll067+b6Pg

=head1 METHODS

=head2 morphology

Converts the string in $self->code to a Lingua::Features::Structure object
and returns the object.

=cut

sub morphology {
	my $self = shift;
	
	# We're trying to read, not write. Get the string and convert it to a Structure.
	my $str = $self->code;
	my $struct;
	if( $str ) {
		# This will croak if $str is not a valid tag
		$struct = Lingua::TagSet::Perseus->tag2structure( $str );
	};
	return $struct;	
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
