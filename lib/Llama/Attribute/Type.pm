package Llama::Attribute::Type;
use Llama::Base qw(+Base::Hash :signatures :constructor);

use Data::Printer;

my $Any = sub{1};

sub parse ($class, @args) {
  die "wrong number of arguments expected at least 1 got ${\ int @args} instead" if @args < 1;
  return $class->new(@args) if @args > 1;

  my $value = $args[0];
  my $ref   = ref $value;
  return $class->new(%$value)           if $ref eq 'HASH';
  return $class->new(default => $value) if $ref eq 'CODE';
  
  return $class->new(value => $value);
}

sub BUILD ($self, %attributes) {
  $self->{mutable}  = $attributes{mutable}  // 0;
  $self->{value}    = $attributes{value}    // $Any;
  $self->{optional} = $attributes{optional} // 0;
  $self->{default}  = $attributes{default};
  $self->freeze;
}

sub default ($self) { $self->{default} }
sub value ($self) { $self->{value} }
sub is_mutable  ($self) { $self->{mutable} }
sub is_optional ($self) { $self->{optional} }

sub is_valid ($self, $value) {
  my $validator = $self->{value} // $Any;
  return !!$validator->($value);
}

sub Str ($self) {
  my $str = $self->value;
  $str = "Mutable($str)"  if $self->is_mutable;
  $str = "Optional($str)" if $self->is_optional;
  return $str;
}

1;
