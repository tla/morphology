#!/usr/bin/env perl

use inc::Module::Install;
author( 'Tara L Andrews <aurum@cpan.org>' );
license( 'perl' );
perl_version( '5.012' );
all_from( 'lib/Lingua/Morph/Perseus.pm' );
requires('DBIx::Class::Schema');
requires('DBIx::Class::Core');
requires('Lingua::Features::Structure');
requires('Lingua::TagSet');
requires('Module::Load');
requires('Moose');
requires('TryCatch');
requires('Unicode::Normalize');

build_requires( 'Test::Warn' );
# Modules needed for morphology but not trivially CPANnable
recommends( 'Lingua::TreeTagger' );
&WriteAll;
