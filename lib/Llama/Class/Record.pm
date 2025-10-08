package Llama::Class::Record;
use Llama::Prelude qw(+Class::Product :signatures);

use Llama::Record;

sub new ($self, @args) {
  my $class = $self->next::method(@args);
  $class->superclasses('Llama::Record');

  return $class;
}

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

    $self->{$name} = $args[0];
    return $self;
  });

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
