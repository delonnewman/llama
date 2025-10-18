package Llama::Class::Hash;
use Llama::Prelude qw(+Class :signatures);

sub add_attribute ($self, @args) {
  my $attribute  = $self->next::method(@args);
  my $name       = $attribute->name;
  my $is_mutable = $attribute->is_mutable;

  $self->add_method($name => sub ($self, @args) {
    return $self->{$name} unless @args;

    my $caller = caller;
    unless ($is_mutable || $self->isa($caller)) {
      die "AttributeError: can't write to readonly attribute: $name";
    }

    $self->{$name} = $self->class->attribute($name)->type->parse($args[0]);
    return $self;
  });

  return $attribute;
}

1;
