package Llama::Attribute::Type;
use Llama::Prelude qw(+Base::Hash :signatures);

my $Any = sub{1};

sub parse ($class, @args) {
  return $class->new(value => 'Any') if @args < 1;
  return $class->new(@args)          if @args > 1;

  my $value = $args[0];
  my $ref   = ref $value;
  return $class->new(%$value)           if $ref eq 'HASH';
  return $class->new(default => $value) if $ref eq 'CODE';
  
  return $class->new(value => $value);
}

sub BUILD ($self, %attributes) {
  $self->{mutable}  = delete $attributes{mutable}  // 0;
  $self->{value}    = delete $attributes{value}    // $Any;
  $self->{optional} = delete $attributes{optional} // 0;
  $self->{order}    = delete $attributes{order}    // 0;
  $self->{default}  = delete $attributes{default};
  $self->{options}  = {%attributes};
  $self->freeze;
}

sub default     ($self) { $self->{default} }
sub value       ($self) { $self->{value} }
sub is_mutable  ($self) { $self->{mutable} }
sub is_optional ($self) { $self->{optional} }
sub order       ($self) { $self->{order} }
sub options     ($self) { $self->{options} }

sub is_valid ($self, $value) {
  my $validator = $self->{value} // $Any;
  return !!$validator->($value);
}

sub toStr ($self) {
  my $str = $self->value;
  $str = "Mutable($str)"  if $self->is_mutable;
  $str = "Optional($str)" if $self->is_optional;
  return $str;
}

1;
