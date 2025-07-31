package Llama::HashObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Llama::Object qw(:base :constructor);

sub allocate ($class, %attributes) {
  bless {
    %attributes,
    -object_id => Llama::Object->OBJECT_ID
  }, $class;
}

sub object_id ($self) { $self->{-object_id} }

1;
