package Llama::CodeObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Llama::Object qw(:base :constructor);

use overload '&{}' => sub{shift->CodeRef};

sub allocate ($class) {
  bless sub{}, $class;
}

sub CodeRef ($self) { $self }

1;
