package Llama::Attribute;
use Llama::Prelude qw(+Base::Hash :signatures);

# Attribute meta object

use Carp ();

use Llama::Delegation;
use Llama::Attribute::Type;

my $Any = sub{1};

sub BUILD ($self, $name, @args) {
  $self->{name} = $name;
  $self->{type} = Llama::Attribute::Type->build(@args);
  $self->instance->freeze;
}

delegate [qw(is_mutable is_optional is_valid default order options)] => 'type';

sub is_required ($self) { !$self->is_optional }

sub value_type ($self) { $self->type->value }
sub type ($self) { $self->{type} }
sub name ($self) { $self->{name} }

sub validate_writable ($self) {
  Carp::confess $self->name . " is not writable" unless $self->is_mutable;
  $self;
}

sub validate ($self, $value) {
  Carp::confess "invalid value: '$value'" unless $self->is_valid($value);
  $self;
}

1;
