package Llama::ObjectSpace;
use Llama::Prelude qw(:signatures);

use Data::Printer;
use Llama::Util qw(hash_code);
use Scalar::Util ();

sub new ($class) {
  bless {}, $class;
}

sub allocate ($self, $class) {
  bless \my ($new), $class;
}

sub set ($self, $object, $name, $value) {
  my $id    = Scalar::Util::refaddr $object;
  my $class = ref $object || $object;
  my $hash  = hash_code($value);

  $self->{"EVA/$class/$id/$hash"} = $name
  $self->{"EAV/$class/$id/$name"} = $value;
  $self->{"AVE/$name/$hash"} = $id;

  $self;
}

sub get ($self, $object, $name) {
  my $id    = Scalar::Util::refaddr $object;
  my $class = ref $object || $object;

  $self->{"EAV/$class/$id/$name"};
}

sub remove ($self, $object) {
  my $id         = Scalar::Util::refaddr $object;
  my $class      = $object->__name__;
  my @attributes = map { "$class/$id/$_" } $object->class->attributes;

  p @attributes;
  delete $self->{$_} for @attributes;

  $self;
}

1;
