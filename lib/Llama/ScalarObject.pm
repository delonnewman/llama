package Llama::ScalarObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object;

sub allocate ($class, $value) {
  bless \$value, $class;
}

1;
