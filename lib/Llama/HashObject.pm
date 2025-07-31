package Llama::HashObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Llama::Object;

sub allocate ($class, %attributes) {
  Carp::confess "abstract classes cannot be allocated"
    if $class eq __PACKAGE__;

  bless \%attributes, $class;
}

1;
