package Llama::Object;
use Llama::Prelude qw(+Base :signatures);

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Package;
use Llama::Delegation;

sub new ($class, $object) {
  Carp::croak "TypeError: can only reflect on objects, got " . np($object) unless Scalar::Util::blessed($object);
  bless \$object, $class;
}

sub subject ($self) { $$self }

delegate [qw(attributes get_attribute_value methods)] => 'class';
delegate [qw(add_attribute add_method set_attribute_value)] => 'eigen_class';

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
