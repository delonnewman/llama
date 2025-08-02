package Llama::ScalarObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object qw(:base :constructor);

use overload bool => sub{1};

sub allocate ($class, $value) {
  bless \$value, $class;
}

sub value ($self) { $$self }
sub to_int ($self) { int($self->value) }

1;
