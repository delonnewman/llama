package Llama::ScalarObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object;

sub allocate ($class, $value) {
  Carp::confess "abstract classes cannot be allocated"
    if $class eq __PACKAGE__;

  bless \$value, $class;
}

1;
