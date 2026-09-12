package Llama::ObjectSpace;
use Llama::Prelude qw(+Base::Symbol :signatures);

use Scalar::Util ();

our %DATA;

sub allocate ($self, $class) {
  bless \my ($new), $class;
}

sub set ($self, $object, $name, $value) {
  my $id    = Scalar::Util::refaddr $object;
  my $class = ref $object || $object;

  $DATA{"$class/$id/$name"} = $value;

  $self;
}

sub get ($self, $object, $name) {
  my $id    = Scalar::Util::refaddr $object;
  my $class = ref $object || $object;

  $DATA{"$class/$id/$name"};
}

sub remove ($self, $object) {
  my $id         = Scalar::Util::refaddr $object;
  my $class      = $object->__name__;
  my @attributes = map { "$class/$id/$_" } $object->class->attributes;

  delete @DATA{@attributes};

  $self;
}

1;
