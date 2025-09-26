package Llama::Pair;
use Llama::Base qw(+Base::Array :signatures);

use overload '%{}' => sub{shift->HashRef};

sub BUILD ($self, $key, $value) {
  $self->[0] = $key;
  $self->[1] = $value;
}

sub key   ($self) { $self->[0] }
sub value ($self) { $self->[1] }

sub Str ($self) { $self->key . ' => ' . $self->value }

sub HashRef  ($self) {
  return {
    $self->key => $self->value
  };
}

1;
