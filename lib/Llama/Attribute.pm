package Llama::Attribute;
use strict;
use warnings;
use utf8;
use feature 'signatures';

# Attribute meta object

use Carp ();

use Llama::Object qw(+HashObject :constructor);

my @ATTRIBUTES = qw(name type validate);

sub BUILD ($self, $name, %options) {
  %$self = (name => $name, %options);
  $self->LOCK(@ATTRIBUTES);
}

sub name ($self) { $self->{name} }

sub is_valid ($self, $value) {
  my $validator = $self->{validate};
  return 1 unless $validator;

  $validator->($value);
}

sub validate ($self, $value) {
  Carp::confess "invalid value: '$value'" unless $self->is_valid($value);
}

1;
