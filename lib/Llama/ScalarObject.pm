package Llama::ScalarObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object qw(:base :constructor);

use Scalar::Util ();

use overload
  '0+' => sub{shift->Num}
  '${}' => sub{shift->ScalarRef};

sub allocate ($class, $value) {
  bless \$value, $class;
}

sub value ($self) { $$self }

sub looks_like_number ($self) {
  Scalar::Util::looks_like_number($self->value)
}

sub Num ($self) { 0+$self->value }
sub Int ($self) { int($self->value) }
sub ScalarRef ($self) { $self }

1;
