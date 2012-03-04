use utf8;
package Morph::Perseus::Result::Token;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morph::Perseus::Result::Token

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tokens>

=cut

__PACKAGE__->table("tokens");

=head1 ACCESSORS

=head2 tokenid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 seq

  data_type: 'integer'
  is_nullable: 1

=head2 type

  data_type: 'text'
  is_nullable: 1

=head2 file

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "tokenid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "seq",
  { data_type => "integer", is_nullable => 1 },
  "type",
  { data_type => "text", is_nullable => 1 },
  "file",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tokenid>

=back

=cut

__PACKAGE__->set_primary_key("tokenid");


# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-03-04 21:54:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AcFIW3B8ETVMtWMIOTyOuw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
