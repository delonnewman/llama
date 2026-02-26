package Llama::Callable;
use Llama::Prelude qw(:signatures);

use Llama::Exception;

sub call ($self, @args) {
  die Llama::NotImplementedError->new('must be implemented by subclasses');
}

sub toCodeRef ($self) {
  return sub { $self->call(@_) };
}

sub partial ($self, @outer) {
  return sub (@inner) { $self->call(@outer, @inner) }
}

1;
