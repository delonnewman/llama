package Llama::Attribute::Type;
use Llama::Base qw(+Base::Hash :signatures :constructor);

use Data::Printer;

my $Any = sub{1};

sub parse ($class, @args) {
  die "wrong number of arguments expected at least 1 got ${\ int @args} instead" if @args < 1;
  return $class->new(@args) if @args > 1;

  my $value = $args[0];
  my $ref   = ref $value;
  return $class->new(%$value) if $ref eq 'HASH';

  die "don't know how to parse " . np($value);
}

sub BUILD ($self, %attributes) {
  $self->{mutable}  = $attributes{mutable}  // 0;
  $self->{value}    = $attributes{value}    // $Any;
  $self->{optional} = $attributes{optional} // 0;
  $self->freeze;
}

sub is_mutable  ($self) { $self->{mutable} }
sub is_optional ($self) { $self->{optional} }

sub is_valid ($self, $value) {
  my $validator = $self->{value} // $Any;
  return !!$validator->($value);
}

1;
