package Llama::CodeObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Llama::Object;

sub allocate ($class, $sub) {
  Carp::confess "abstract classes cannot be allocated"
    if $class eq __PACKAGE__;

  my $type = ref($sub);
  Carp::confess "invalid reference type: '$type'"
    unless $type eq 'CODE';

  bless $sub, $class;
}

1;
