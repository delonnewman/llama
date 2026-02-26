package Llama::Attribute::Type;
use Llama::Prelude qw(+Base::Hash :signatures);

use Carp ();
use Data::Printer;
use Feature::Compat::Try;
use Scalar::Util qw(blessed);

my $Any = sub{1};

sub build ($class, @args) {
  return $class->new(value => 'Any') if @args < 1;
  return $class->new(@args)          if @args > 1;

  my $value = $args[0];
  my $ref   = ref $value;
  return $class->new(%$value)           if $ref eq 'HASH';
  return $class->new(default => $value) if $ref eq 'CODE';
  
  return $class->new(value => $value);
}

sub BUILD ($self, %attributes) {
  $self->{mutable}     = delete $attributes{mutable}  // 0;
  $self->{value}       = delete $attributes{value};
  $self->{optional}    = delete $attributes{optional} // 0;
  $self->{order}       = delete $attributes{order}    // 0;
  $self->{default}     = delete $attributes{default};
  $self->{class}       = delete $attributes{class};
  $self->{cardinality} = delete $attributes{cardinality};
  $self->{options}     = {%attributes};
  $self->instance->freeze;
}

sub default     ($self) { $self->{default} }
sub value       ($self) { $self->{value} }
sub is_mutable  ($self) { $self->{mutable} }
sub is_optional ($self) { $self->{optional} }
sub order       ($self) { $self->{order} }
sub options     ($self) { $self->{options} }
sub class_name  ($self) { $self->{class} }
sub cardinality ($self) { $self->{cardinality} }

sub parse ($self, $value) {
  return $value unless $self->class_name;

  return $self->class_name->parse($value) unless $self->cardinality eq 'many';

  my @results = map { $self->class_name->parse($_) } @$value;
  return \@results unless blessed($results[0]) && $results[0]->isa('Llama::Base::Hash');

  # dedup
  my %results = map { $_->__hash__ => $_ } @results;
  return [values %results];
}

sub is_valid ($self, $value) {
  try {
    $self->parse($value);
    return 1;
  } catch ($e_) {
    return 0;
  }
}

sub toStr ($self) {
  my $str = $self->value || $self->class_name;
  $str = "Mutable($str)"  if $self->is_mutable;
  $str = "Optional($str)" if $self->is_optional;
  return $str;
}

1;
