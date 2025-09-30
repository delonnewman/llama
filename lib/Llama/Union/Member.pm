package Llama::Union::Member;

=encoding utf8

=head1 NAME

Llama::Union::Member

=head2 DESCRIPTION

A meta class for building enum members (see L<Llama::Union> and L<Llama::Union::Class>)

=cut

use Llama::Base qw(:base :signatures);

use Scalar::Util qw(blessed);

no strict 'refs';

# Class Methods

sub new ($class, $union_class, $key) {
  bless [$union_class, $key], $class;
}

# Attributes

sub union_class ($self) { $self->[0] }
sub key ($self) { $self->[1] }
sub name ($self) { join '::' => @$self }

# Instance Methods

sub build ($self) {
  return if ${$self->union_class . '::MEMBERS'}{$self->key};

  # Make member class a subclass of the union class
  $self->subclass($self->union_class);

  # Create member instance
  my $name     = $self->name;
  my $instance = bless \$name, $name;

  # Add enum class method for accessing this instance e.g MyEnum->KEY
  $self->add_accessor_method($instance);

  # Update index
  ${$self->union_class . '::MEMBERS'}{$self->key} = $instance;

  return $self;
}

sub subclass ($self, $superclass) {
  push @{$self->name . '::ISA'} => $superclass;
  return $self;
}

sub add_accessor_method ($self, $instance) {
  *{$self->name} = sub :prototype() { $instance };
  return $self;
}

1;
