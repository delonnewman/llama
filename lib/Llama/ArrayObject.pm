package Llama::ArrayObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object;

sub allocate ($class, @values) {
  Carp::confess "abstract classes cannot be allocated"
    if $class eq __PACKAGE__;

  bless \@values, $class;
}

1;
