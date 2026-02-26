package Llama::Attribute::Type;
use Llama::Prelude qw(+Base::Hash :signatures);

use Carp ();
use Data::Printer;
use Feature::Compat::Try;
use Scalar::Util qw(blessed);

use Llama::Parser::Data ();
use Llama::Attribute::TypeRegistry;

my $Any = sub{1};

sub registry ($self) {
  state $registry = do {
    Llama::Attribute::TypeRegistry->new
      ->add(Defined    => \&Llama::Parser::Data::Defined)
      ->add(Any        => \&Llama::Parser::Any)
      ->add(Bool       => \&Llama::Parser::Data::Bool)
      ->add(Num        => \&Llama::Parser::Data::Num)
      ->add(Str        => \&Llama::Parser::Data::Str)
      ->add(Tuple      => \&Llama::Parser::Data::Tuple)
      ->add(Array      => \&Llama::Parser::Data::Array)
      ->add(InstanceOf => \&Llama::Parser::Data::InstanceOf);
  };
}

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

  if (!$self->{value}) {
    $self->{parser} = Llama::Parser::Any();
  } else {
    my $parser = $self->registry->parse($self->{value});
    if (blessed($parser)) {
      $self->{parser} = $parser
    } else {
      $self->{parser} = Llama::Parser::Data::InstanceOf($parser);
    }
  }

  $self->instance->freeze;
}

sub default     ($self) { $self->{default} }
sub value       ($self) { $self->{value} }
sub parser      ($self) { $self->{parser} }
sub is_mutable  ($self) { $self->{mutable} }
sub is_optional ($self) { $self->{optional} }
sub order       ($self) { $self->{order} }
sub options     ($self) { $self->{options} }
sub class_name  ($self) { $self->{class} }
sub cardinality ($self) { $self->{cardinality} }

sub parse ($self, $value) {
  $self->parser->parse($value);
}

sub is_valid ($self, $value) {
  $self->parser->is_valid($value);
}

sub toStr ($self) {
  my $str = $self->value || $self->class_name;
  $str = "Mutable($str)"  if $self->is_mutable;
  $str = "Optional($str)" if $self->is_optional;
  return $str;
}

1;
