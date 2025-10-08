package Llama::Class::Record;
use Llama::Prelude qw(+Class::Product :signatures);

sub add_attribute ($self, @args) {
  my $attribute  = $self->next::method(@args);
  my $name       = $attribute->name;

  $self->add_method($name => sub ($self) { $self->{$name} });

  return $attribute;
}

sub Str ($self) {
  my $class = $self->name;

  no strict 'refs';
  my %attributes = %{$class . '::ATTRIBUTES'};
  my $pairs = join ', ' => map { $_ . ' => ' . $attributes{$_}->type } keys %attributes;

  return $pairs ? "$class($pairs)" : $class;
}

1;
