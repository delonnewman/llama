package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);

sub assign_attributes ($self, @args) {
  return unless @args;

  my %attributes = @args > 1 ? @args : $args[0]->%*;
  $self->$_($attributes{$_}) for $self->class->attributes;

  return $self;
}

1;
