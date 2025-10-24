package Llama::Item;
use Llama::Prelude qw(+Base::Hash :signatures);

use Carp ();
use Data::Printer;
use experimental 'lexical_subs';

sub BUILD ($self, @args) {
  if (!@args && (my @required = $self->class->required_attributes)) {
    Carp::croak "ArgumentError: missing required attribute(s): " . join(', ' => @required);
  }
  $self->parse(@args);
}

my sub attribute_value ($self, $attribute, $value) {
  my $name    = $attribute->name;
  my $default = $attribute->default;

  $value = $self->$default() if $default && !defined($value);

  return $value;
}

sub parse ($self, @args) {
  Carp::croak "ParseError: can't parse an empty value" unless @args || ref $self;
  return unless @args;
  $self = $self->allocate unless ref $self;

  my %errors = ();
  my %attributes = @args > 1 ? @args : $args[0]->%*;
  for my $name ($self->class->attributes) {
    my $attribute = $self->class->attribute($name);
    my $value     = attribute_value($self, $attribute, $attributes{$name});
    if (defined $value) {
      $self->{$name} = $attribute->type->parse($value);
      next;
    }
    $errors{$name} = 'is required' if $attribute->is_required;
  }

  if (%errors) {
    my $messages   = join "\n" => map { "$_ $errors{$_}" } keys %errors;
    Carp::croak "ParseError: $messages\n from data: " . np(%attributes);
  }

  return $self;
}

sub has_one ($self, $attribute_name) {
  return !!$self->{$attribute_name};
}

sub has_some ($self, $attribute_name) {
  my $val = $self->{$attribute_name};
  return $val && $val->@*;
}

sub with ($self, %attributes) {
  my %args = ($self->toHash, %attributes);
  return $self->new(%args);
}

sub toStr ($self) {
  my $class = $self->__name__;

  my @pairs = $self->META->pairs;
  return $class unless @pairs;

  my $pairs = join ', ' => map { $_->key . ' => ' . $_->value } grep { $_->value } @pairs;
  return "$class($pairs)";
}

1;
