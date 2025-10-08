package Llama::Class;
use Llama::Prelude qw(+Base :signatures);

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Package;
use Llama::Attribute;
use Llama::Class::InstanceCache;

our $DEFAULT_MRO = 'c3';

no strict 'refs';
no warnings qw(once);

sub named ($class, $name) {
  my $object = Llama::Class::InstanceCache->get($name);
  $object //= Llama::Class::InstanceCache->set($name, $class->new($name));
  $object;
}

sub new ($class, $name = undef) {
  my $kind = $name ? ${$name . '::ATTRIBUTE_DATA'}{__kind__} // $class : $class;
  $name //= '';

  my $self = bless \$name, $kind;

  # generate name
  $name .= "$class=OBJECT(" . sprintf("0x%06X", $self->__addr__) . ')' unless $name;

  $self->mro($DEFAULT_MRO);
  $self->kind($kind);

  return $self;
}

sub name ($self) { $$self }
*Str = \&name;

sub kind ($self, @args) {
  if (@args) {
    Llama::Class::InstanceCache->invalidate($self->name);
    ${$self->package->qualify('ATTRIBUTE_DATA')}{__kind__} = $args[0];
    return $self;
  }

  return ${$self->package->qualify('ATTRIBUTE_DATA')}{__kind__} // $self->__name__;
}

sub new_instance ($self, @args) { $self->name->new(@args) }

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

  my @isa = $self->package->ISA;
  return wantarray ? @isa : \@isa;
}
*parents = \&superclasses;

sub is_subclass ($self, $class) {
  return $self->name->isa($class);
}

sub subclass ($self, $name = undef) {
  Llama::Class->new($name)->superclasses($self->name);
}
*inherit = \&subclass;

sub append_superclasses($self, @classes) {
  push $self->package->ISA->@*, @classes;
  return $self;
}

sub prepend_superclasses($self, @classes) {
  unshift $self->package->ISA->@*, @classes;
  return $self;
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
  no warnings 'once';
  ${$self->package->qualify('ATTRIBUTES')}{$attribute->name} = $attribute;

  $attribute;
}

sub attribute ($self, $name) {
  no strict 'refs';

  my $attribute;
  for ($self->ancestry) {
    $attribute = ${$_ . '::ATTRIBUTES'}{$name};
    last if $attribute;
  }

  Carp::confess "unknown attribute '$name'" unless $attribute;
  return $attribute;
}

=pod

head2 attributes

  $class->attributes # => Llama::Schema

=cut

sub attributes ($self) {
  no strict 'refs';
  my @attributes = map { $_->name } $self->ATTRIBUTES;
  wantarray ? @attributes : \@attributes;
}

sub readonly_attributes ($self) {
  no strict 'refs';
  my @attributes = map { $_->name } grep { !$_->is_mutable } $self->ATTRIBUTES;
  wantarray ? @attributes : \@attributes;
}

sub required_attributes ($self) {
  my @attributes = map { $_->name } grep { $_->is_required && !$_->default } $self->ATTRIBUTES;
  wantarray ? @attributes : \@attributes;
}

sub optional_attributes ($self) {
  my @attributes = map { $_->name } grep { $_->is_optional } $self->ATTRIBUTES;
  wantarray ? @attributes : \@attributes;
}

sub ATTRIBUTES ($self) {
  no strict 'refs';

  my @attributes =
    sort { $a->order <=> $b->order }
    map { values %{Llama::Package->named($_)->qualify('ATTRIBUTES')} }
    $self->ancestry;

  wantarray ? @attributes : \@attributes;
}

sub set_attribute_value ($self, $name, $value) {
  no strict 'refs';

  my $attribute = $self->attribute($name);
  $attribute->validate_writable->validate($value);
  ${$self->package->qualify('ATTRIBUTE_DATA')}{$name} = $value;

  return $self;
}

sub get_attribute_value ($self, $name) {
  no strict 'refs';
  ${$self->package->qualify('ATTRIBUTE_DATA')}{$name};
}


1;
