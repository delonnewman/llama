package Llama::Attribute;
use Llama::Base qw(+HashObject :constructor :signatures);

# Attribute meta object

use Carp ();

my @ATTRIBUTES = qw(name type validate mutable);

sub BUILD ($self, $name, %options) {
  %$self = (name => $name, %options);
  $self->{validate} = $options{validate} // sub {1};
  $self->lock(@ATTRIBUTES);
}

sub name ($self) { $self->{name} }

sub is_mutable ($self) { !!$self->{mutable} }

sub is_valid ($self, $value) {
  my $validator = $self->{validate};
  return 1 unless $validator;

  $validator->($value);
}

sub validate_writable ($self) {
  Carp::confess $self->name . " is not writable" unless $self->is_mutable;
  $self;
}

sub validate ($self, $value) {
  Carp::confess "invalid value: '$value'" unless $self->is_valid($value);
  $self;
}

1;
