package Llama::Object;
use strict;
use warnings;
use utf8;
use feature 'signatures';
no strict 'refs';

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Perl::Package;

sub new ($class, $object) {
  bless sub{$object}, $class;
}

sub subject ($self) { $self->() }

sub add_attribute ($self, @args) {
  my $class     = $self->eigen_class;
  my $attribute = $class->add_attribute(@args);
  my $name      = $attribute->name;

  if ($attribute->is_mutable) {
    $class->add_instance_method($name => sub ($self, @args) {
      if (@args) {
        $class->set_attribute_value($name, $args[0]);
        return $self;
      }
      return $class->get_attribute_value($name);
    });
  } else {
    $class->add_instance_method($name => sub ($self) {
      return $class->get_attribute_value($name);
    });
  }

  $self;
}

sub eigen_class ($self) {
  return $self->class if $self->CLASS->isa('Llama::Class::EigenClass');

  Llama::Perl::Package
    ->named('Llama::Class::EigenClass')
    ->maybe_load
    ->name
    ->new($self)
}

sub class ($self) {
  Llama::Perl::Package
    ->named('Llama::Class')
    ->maybe_load
    ->name
    ->named($self->class_name)
}

sub class_name ($self) { ref $self->subject }

sub BLESS ($self, $class_name) {
  bless $self->subject, $class_name;
  $self;
}

1;
