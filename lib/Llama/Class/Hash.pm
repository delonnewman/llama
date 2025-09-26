package Llama::Class::Hash;
use Llama::Base qw(+Class :signatures);

sub add_attribute ($self, @args) {
  my $attribute  = $self->next::method(@args);
  my $name       = $attribute->name;
  my $is_mutable = $attribute->is_mutable;

  $self->add_method($name => sub ($self, @args) {
    return $self->{$name} unless @args;

    my $caller = caller;
    die "can't write to readonly attribute: $name" unless $is_mutable || $self->isa($caller);

    $self->{$name} = $args[0];
    return $self;
  });

  return $attribute;
}

1;
