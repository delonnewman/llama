package Llama::HashObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object qw(:base :constructor);

use overload '%{}' => sub{shift->HashRef};

sub allocate ($class) {
  bless {}, $class;
}

sub HashRef ($self) { $self }

1;
