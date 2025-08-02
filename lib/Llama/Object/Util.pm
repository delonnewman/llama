package Llama::Object::Util;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Exporter 'import';
our @EXPORT_OK = qw(add_abstract_method);

sub add_abstract_method ($package, $name, $message = undef) {
  $message //= 'not implemented';
  {
    no strict 'refs';
    *{$package . '::' . $name} = sub { Carp::confess $message };
  }
}

1;
