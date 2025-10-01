package Llama::Union::Member;

=encoding utf8

=head1 NAME

Llama::Union::Member

=head2 DESCRIPTION

A meta class for building enum members (see L<Llama::Union> and L<Llama::Union::Class>)

=cut

use Llama::Base qw(+Class :signatures);

use Scalar::Util qw(blessed);

no strict 'refs';

# Instance Methods

sub build ($self, $union_class, $key) {
  return if ${$union_class . '::MEMBERS'}{$key};
  $self = $self->new(join '::' => $union_class, $key) unless blessed($self);

  # Make member class a subclass of the union class
  $self->superclasses($union_class);

  # Create member instance
  my $name     = join '::' => $union_class, $key;
  my $instance = bless \$name, $name;

  # Add enum class method for accessing this instance e.g MyEnum->KEY
  $self->add_method($name, sub { $instance });

  # Update index
  ${$union_class . '::MEMBERS'}{$key} = $instance;

  return $self;
}

1;
