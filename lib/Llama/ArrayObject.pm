package Llama::ArrayObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object;

sub allocate ($class, @values) {
  bless \@values, $class;
}

1;
