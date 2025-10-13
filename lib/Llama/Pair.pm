package Llama::Pair;
use Llama::Prelude qw(+Base::Array :signatures);

use overload '%{}' => sub{shift->HashRef};

sub BUILD ($self, $key, $value) {
  $self->[0] = $key;
  $self->[1] = $value;
}

sub key   ($self) { $self->[0] }
sub value ($self) { $self->[1] }

sub toStr ($self) {
  $self->key . ' => ' . (defined $self->value ? $self->value : 'undef');
}

sub toArray ($self) {
  my @array = ($self->key, $self->value);
  wantarray ? @array : \@array;
}

sub toHash ($self) {
  my %hash = ($self->key => $self->value);
  wantarray ? %hash : \%hash;
}

sub toHashRef  ($self) {
  return {
    $self->key => $self->value
  };
}

1;
