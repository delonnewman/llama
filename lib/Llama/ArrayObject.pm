package Llama::ArrayObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object qw(:base :constructor);

use overload '@{}' => sub{shift->ArrayRef};

sub allocate ($class, @values) {
  bless \@values, $class;
}

sub ArrayRef ($self) { $self }

1;
