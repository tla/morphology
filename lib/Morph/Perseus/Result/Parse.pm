use utf8;
package Morph::Perseus::Result::Parse;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morph::Perseus::Result::Parse

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<parses>

=cut

__PACKAGE__->table("parses");

=head1 ACCESSORS

=head2 parseid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 tokenid

  data_type: 'int'
  is_nullable: 1

=head2 lex

  data_type: 'int'
  is_nullable: 1

=head2 code

  data_type: 'text'
  is_nullable: 1

=head2 lemma

  data_type: 'text'
  is_nullable: 1

=head2 authority

  data_type: 'text'
  is_nullable: 1

=head2 file

  data_type: 'text'
  is_nullable: 1

=head2 prob

  data_type: 'float'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "parseid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "tokenid",
  { data_type => "int", is_nullable => 1 },
  "lex",
  { data_type => "int", is_nullable => 1 },
  "code",
  { data_type => "text", is_nullable => 1 },
  "lemma",
  { data_type => "text", is_nullable => 1 },
  "authority",
  { data_type => "text", is_nullable => 1 },
  "file",
  { data_type => "text", is_nullable => 1 },
  "prob",
  { data_type => "float", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</parseid>

=back

=cut

__PACKAGE__->set_primary_key("parseid");


# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-03-04 21:54:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9GUfqkHk3KZRamdkDC0lrQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
