package Llama::Function::Generic;
use Llama::Prelude qw(+Base :signatures);

sub call ($self, $tag, @args) {
  return $self->$tag(@args);
}

1;
