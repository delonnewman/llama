package Llama::HashObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object;

sub allocate ($class, %attributes) {
  bless \%attributes, $class;
}

1;
