package Llama::Class;
use strict;
use warnings;
use utf8;
use feature 'signatures';
use feature 'state';

no strict 'refs';

use Scalar::Util ();

use Llama::Attribute;
use Llama::Object qw(:base);
use Llama::Perl::Package;

use Llama::Class::AnonymousClass;
use Llama::Class::EigenClass;
use Llama::Class::InstanceCache;

our $DEFAULT_MRO = 'c3';

sub own ($class, $object) {
  Llama::Class::EigenClass->new($object);
}

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

sub version ($self) { $self->package->VERSION }

sub mro ($self, @args) {
  if (@args) {
    mro::set_mro($self->name, $args[0]);
    return $self;
  }

  mro::get_mro($self->name);
}

sub package ($self) { Llama::Perl::Package->named($self->name) }
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

sub add_method ($self, $name, $sub) {
  $self->package->add_sub($name, $sub);
  $self;
}

sub add_attribute ($self, @args) {
  my $attribute = Llama::Attribute->new(@args);
  push @{$self->package->qualify('ATTRIBUTES')}, $attribute;
  $self;
}

sub attributes ($self, @args) {
  my @attributes = @{$self->package->qualify('ATTRIBUTES')};
  wantarray ? @attributes : [@attributes];
}

sub methods ($self) {
  my @methods = map {
    Llama::Perl::Package->named($_)->symbol_names('CODE')
  } $self->ancestry;

  wantarray ? @methods : [@methods];
}

1;
