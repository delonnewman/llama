package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);

sub assign_attributes ($self, @args) {
  return unless @args;

  my %attributes = @args > 1 ? @args : $args[0]->%*;
  $self->$_($attributes{$_} // die "$_ is required") for $self->class->required_attributes;
  $self->$_($attributes{$_}) for $self->class->optional_attributes;

  return $self;
}

1;
