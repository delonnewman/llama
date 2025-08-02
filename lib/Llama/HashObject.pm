package Llama::HashObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Llama::Object qw(:base :constructor);

sub allocate ($class, %attributes) {
  bless \%attributes, $class;
}

1;
