package Llama::Base;

use strict;
use warnings;
use utf8;
use feature ':5.20';
use experimental 'signatures';
use mro;
no strict 'refs';
no warnings 'once';

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Exception;
use Llama::ObjectSpace;
use Llama::Method;
use Llama::Package;

use overload
  'bool' => sub { shift->toBool },
  '""'   => sub { shift->toStr };

our $OBJECT_SPACE = Llama::ObjectSpace->new;

# Protect subclasses using AUTOLOAD
sub DESTROY ($self) {
  Llama::ObjectSpace->new->remove($self);
}

sub new ($self, @args) {
  my $class = ref($self) || $self;

  my $object = $class->allocate;
  $object->try('BUILD', @args);
  $object->try('ADJUST');

  return $object;
}

sub allocate ($self) {
  $OBJECT_SPACE->allocate($self->__name__);
}

sub BUILD ($self, %attributes) {
  $self->assign_attributes(%attributes);
}

sub set_attribute ($self, $name, $value) {
  $OBJECT_SPACE->set($self, $name, $value);
}

sub attribute_value ($self, $name) {
  $OBJECT_SPACE->get($self, $name);
}

sub assign_attributes ($self, %attributes) {
  for my $name (keys %attributes) {
    $OBJECT_SPACE->set($self, $name, $attributes{$name});
  }

  $self;
}

sub META ($self) {
  return $self->class unless ref $self;
  return $self->instance;
}

sub class ($self) {
  my $kind   = $self->try('__kind__') // 'Llama::Class';
  my $mirror = Llama::Package->named($kind)->maybe_load;
  my $class  = $mirror->name->named($self->__name__);

  return $class unless $class->isa('Llama::Class::EigenClass');
  return $mirror->name->named($class->progenitor);
}

sub __kind__ { 'Llama::Class' }

sub instance ($self) {
  return Llama::Package->named('Llama::Object')->maybe_load->name->new($self);
}

sub __name__ ($self) { ref($self) || $self }
sub __type__ ($self) { Scalar::Util::reftype($self) }
sub __addr__ ($self) { Scalar::Util::refaddr($self) }
*__id__   = \&__addr__;
*__hash__ = \&__addr__;

sub identical ($self, $other) { $self->__id__ eq $other->__id__ }
*equals  = \&identical;
*matches = \&identical;

sub toBool { 1 }

sub toStr ($self) {
  my $class = $self->__name__;
  my $id    = sprintf("0x%06X", $self->__id__);

  return "$class=OBJECT($id)";
}

sub try ($self, $method_name, @args) {
  if (my $method = $self->can($method_name)) {
    return $self->$method(@args);
  }
}

sub then ($self, $sub_or_method_name, @args) {
  return $_->$sub_or_method_name(@args) for $self;
}

sub tap ($self, $sub_or_method_name, @args) {
  $_->$sub_or_method_name(@args) for $self;
  return $self;
}

sub itself ($self, @args) { $self }

*if_null   = \&itself;
*if_falsy  = \&itself;
*if_truthy = \&tap;

sub if   ($self, @args) { $self->if_truthy(@args) }
sub else ($self, @args) { $self->if_falsy(@args) }

sub bind ($self, $name, @args) {
  Llama::Method->new($self, $name, @args)
}

*method = \&bind;

1;

__END__

package Person {
  use Llama::Prelude qw(+Base :signatures);
  sub name ($self) { $self->attribute_value('name') }
  sub age ($self) { $self->attribute_value('age') }
}

Person->new(name => 'Delon', age => 63)
Person->new(name => 'Jackie', age => 45)
