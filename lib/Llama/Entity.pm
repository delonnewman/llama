package Llama::Entity;
use Llama::Prelude qw(+Base::Hash :signatures);
use Llama::Attributes;

has 'id' => { default => '__id__' };

sub equals ($self, $other) {
  return !!0 unless $other->isa(__PACKAGE__);

  return $self->id eq $other->id;
}

1;
