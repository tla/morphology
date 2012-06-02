use utf8;
package Lingua::Morph::Perseus::Result::Shortdef;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Lingua::Morph::Perseus::Result::Shortdef

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<shortdefs>

=cut

__PACKAGE__->table("shortdefs");

=head1 ACCESSORS

=head2 lemma

  data_type: 'text'
  is_nullable: 1

=head2 def

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "lemma",
  { data_type => "text", is_nullable => 1 },
  "def",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-03-04 21:54:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S4kDGyBO8Tl7WXZsG1ClEQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
