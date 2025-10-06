package Llama::Object;
use Llama::Base qw(:base :signatures);

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Package;
use Llama::Delegation;

sub new ($class, $object) {
  bless \$object, $class;
}

sub subject ($self) { $$self }

sub add_attribute ($self, @args) {
  my $class     = $self->eigen_class;
  my $attribute = $class->add_attribute(@args);
  my $name      = $attribute->name;

  unless ($attribute->is_mutable) {
    $class->add_instance_method($name => sub ($self) {
      return $class->get_attribute_value($name);
    });
    return $self;
  }

  $class->add_instance_method($name => sub ($self, @args) {
    if (@args) {
      $class->set_attribute_value($name, $args[0]);
      return $self;
    }
    return $class->get_attribute_value($name);
  });

  $self;
}

delegate [qw(attributes get_attribute_value)] => 'class';
delegate [qw(add_method set_attribute_value)] => 'eigen_class';

sub eigen_class ($self) {
  return $self->class if $self->class->isa('Llama::Class::EigenClass');

  Llama::Package
    ->named('Llama::Class::EigenClass')
    ->maybe_load
    ->name
    ->build($self)
}

sub class ($self) {
  Llama::Package
    ->named('Llama::Class')
    ->maybe_load
    ->name
    ->named($self->name)
}

sub name ($self) { ref $self->subject }
sub type ($self) { Scalar::Util::reftype($self->subject) }
sub addr ($self) { Scalar::Util::refaddr($self->subject) }

sub BLESS ($self, $class_name) {
  bless $self->subject, $class_name;
  $self;
}

sub Str ($self) {
  my $class   = $self->__name__;
  my $subject = $self->subject;

  return "$class($subject)";
}

1;
