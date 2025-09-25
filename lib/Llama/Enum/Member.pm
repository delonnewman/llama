package Llama::Enum::Member;

=encoding utf8

=head1 NAME

Llama::Enum::Member

=head2 DESCRIPTION

A meta class for building enum members (see L<Llama::Enum> and L<Llama::Enum::Class>)

=cut

use Llama::Base qw(:base :signatures);
no strict 'refs';

use Scalar::Util qw(blessed);

# Class Methods

sub new ($class, $enum_class, $key) {
  bless [$enum_class, uc $key], $class;
}

# Attributes

sub enum_class ($self) { $self->[0] }
sub key ($self) { $self->[1] }
sub name ($self) { join '::' => @$self }

# Instance Methods

sub build ($self, $value) {
  my $instance = $self->make_instance($value);

  # Add enum class method for accessing this instance e.g MyEnum->KEY
  $self->add_accessor_method($instance);

  # Update indexes
  $self->enum_class->add_key_mapping($self->key, $instance);
  $self->enum_class->add_value_mapping($instance->value, $instance);

  return $self;
}

sub subclass ($self, $superclass) {
  @{$self->name . '::ISA'} = $superclass;
  return $self;
}

sub add_accessor_method ($self, $instance) {
  *{$self->name} = sub :prototype() { $instance };
  return $self;
}

sub make_instance ($self, $value) {
  unless (blessed $value) {
    # Make member class a subclass of the enum class
    $self->subclass($self->enum_class);

    # Create member instance
    return bless \$value, $self->name;
  }

  # Dealing with blessed references...
  my $object = $value;
  my $class  = $self->enum_class;

  # Return instances of member class
  return $object if $object->isa($self->name);

  # Only instances of the enum class can become members
  Carp::croak "only subclass instances can be members $object isn't a subclass of $class" unless $object->isa($class);

  # Make member class a subclass of the value class
  $self->subclass(ref $value);

  # Finally, bless the object into it's member class
  return bless $object, $self->name;
}

1;
