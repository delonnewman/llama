package Llama::Class::Record;
use Llama::Prelude qw(+Class::Product :signatures);

sub add_attribute ($self, @args) {
  my $attribute  = $self->next::method(@args);
  my $name       = $attribute->name;

  $self->add_method($name => sub ($self) { $self->{$name} });

  return $attribute;
}

1;
