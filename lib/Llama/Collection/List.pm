package Llama::Collection::List;
use Llama::Prelude qw(+Base::Array +Collection::Sequence :signatures);

sub first  ($self) { $self->[0] }
sub next   ($self) { $self->[1] }
sub length ($self) { $self->[2] }

sub cons ($self, $value) {
  return $self->__name__->new($value, undef, 1) if $self->is_empty;

  $self->__name__->new($value, $self, $self->length + 1);
}

sub empty ($self) {
  state $empty = $self->__name__->new(undef, undef, 0);
}

sub toStr ($self) {
  my $name    = $self->__name__;
  my $entries = join ', ' => map { "$_" } $self->toArrayRef->@*;

  return "$name($entries)";
}

1;
