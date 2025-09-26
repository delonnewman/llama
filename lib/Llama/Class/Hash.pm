package Llama::Class::Hash;
use Llama::Base qw(+Class :signatures);

sub add_attribute ($self, @args) {
  my $attribute = $self->next::method(@args);
  my $name = $attribute->name;

  unless ($attribute->is_mutable) {
    $self->add_method($name => sub ($self) { $self->{$name} });
    return $self;
  }

  $self->add_method($name => sub ($self, @args) {
    return $self->{$name} unless @args;

    $self->{$name} = $args[0];
    return $self;
  });

  return $attribute;
}

1;
