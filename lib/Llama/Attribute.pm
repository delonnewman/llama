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

sub validate ($self, $value) {

}

1;
