package Llama::Class;
use Llama::Base qw(+Base::Scalar :signatures);

use Data::Printer;
use Scalar::Util ();

use Llama::Package;
use Llama::Attribute;

use Llama::Class::AnonymousClass;
use Llama::Class::EigenClass;
use Llama::Class::InstanceCache;

our $DEFAULT_MRO = 'c3';

no warnings 'experimental::signatures';

sub named ($class, $name) {
  my $object = Llama::Class::InstanceCache->get($name);
  $object //= Llama::Class::InstanceCache->set($name, $class->new($name));
  $object;
}

sub new ($class, $name = undef) {
  return Llama::Class::AnonymousClass->new unless $name;

  my $object = bless \$name, $class;
  $object->mro($DEFAULT_MRO);
  $object;
}

sub name ($self) { $$self }
*Str = \&name;

sub version ($self) { $self->package->version }

sub mro ($self, @args) {
  if (@args) {
    mro::set_mro($self->name, $args[0]);
    return $self;
  }

  mro::get_mro($self->name);
}

sub package ($self) { Llama::Package->named($self->name) }
*module = \&package;

sub ancestry ($self) {
  my $classes = mro::get_linear_isa($self->name, $self->mro);
  wantarray ? @$classes : [@$classes];
}

sub superclasses ($self, @superclasses) {
  if (@superclasses) {
    $self->package->ISA(@superclasses);
    return $self
  }

  $self->package->ISA
}
*parents = \&superclasses;

sub subclass ($self, $name = undef) {
  Llama::Class->new($name)->superclasses($self->name);
}
*inherit = \&subclass;

sub append_superclasses($self, @superclasses) {
  push $self->package->ISA->@*, @superclasses;
  $self;
}

sub prepend_superclasses($self, @superclasses) {
  unshift $self->package->ISA->@*, @superclasses;
  $self;
}

sub add_instance_method ($self, $name, $sub) {
  $self->add_method($name, sub ($self, @args) {
    Carp::confess "instance methods can't be called in a package context" unless ref $self;
    return $sub->(@args);
  });
}

sub add_abstract_method ($self, $name, $message = undef) {
  $message //= "${self}::$name - abstract methods cannot be invoked";
  $self->add_method($name, sub { Carp::confess $message });
}

sub add_method ($self, $name, $sub) {
  $self->package->add_sub($name, $sub);
  $self;
}

# a class is it's own class
sub eigen_class ($self) { $self }

sub methods ($self) {
  my %methods = map {
    $_ => [Llama::Package->named($_)->symbol_names('CODE')]
  } $self->ancestry;

  wantarray ? %methods : \%methods;
}

=pod

head2 add_attribute

  $class->add_attribute($attribute);
  $class->add_attribute($name, mutable => 1, value => 'Str');
  $class->add_attribute($name, { mutable => 1, value => 'Str' });
  $class->add_attribute($name, 'Mutable[Str]');

  my $type = Llama::AttributeType->new(mutable => 1, value => 'Str');
  $class->add_attribute($name, $type);

=cut

sub add_attribute ($self, @args) {
  my $attribute = @args == 1 && $args[0]->isa('Llama::Attribute')
    ? $args[0]
    : Llama::Attribute->new(@args);

  no strict 'refs';
  ${$self->package->qualify('ATTRIBUTES')}{$attribute->name} = $attribute;

  $attribute;
}

sub attribute ($self, $name) {
  no strict 'refs';
  my $attribute = ${$self->package->qualify('ATTRIBUTES')}{$name};
  Carp::confess "unknown attribute '$name'" unless $attribute;
  $attribute;
}

=pod

head2 attributes

  $class->attributes # => Llama::Schema

=cut

sub attributes ($self) {
  no strict 'refs';
  my @attributes = keys %{$self->package->qualify('ATTRIBUTES')};
  wantarray ? @attributes : \@attributes;
}

sub readonly_attributes ($self) {
  no strict 'refs';
  my %attributes = %{$self->package->qualify('ATTRIBUTES')};
  my @attributes = map { $_->name } grep { !$_->is_mutable } values %attributes;
  wantarray ? @attributes : \@attributes;
}

sub required_attributes ($self) {
  no strict 'refs';
  my %attributes = %{$self->package->qualify('ATTRIBUTES')};
  my @attributes = map { $_->name } grep { $_->is_required } values %attributes;
  wantarray ? @attributes : \@attributes;
}

sub optional_attributes ($self) {
  no strict 'refs';
  my %attributes = %{$self->package->qualify('ATTRIBUTES')};
  my @attributes = map { $_->name } grep { $_->is_optional } values %attributes;
  wantarray ? @attributes : \@attributes;
}

sub set_attribute_value ($self, $name, $value) {
  no strict 'refs';
  my $attribute = $self->attribute($name);
  $attribute->validate_writable->validate($value);
  ${$self->package->qualify('ATTRIBUTE_DATA')}{$name} = $value;
}

sub get_attribute_value ($self, $name) {
  no strict 'refs';
  ${$self->package->qualify('ATTRIBUTE_DATA')}{$name};
}

1;
