package Llama::Attribute;
use Llama::Base qw(+Base::Hash :constructor :signatures);

# Attribute meta object

use Carp ();

use Llama::Delegation;
use Llama::Attribute::Type;

my $Any = sub{1};

no warnings 'experimental::signatures';

sub BUILD ($self, $name, @args) {
  $self->{name} = $name;
  $self->{type} = Llama::Attribute::Type->parse(@args);
  $self->freeze;
}

delegate [qw(is_mutable is_optional is_valid)] => 'type';

sub is_required ($self) { !$self->is_optional }

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
