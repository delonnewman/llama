package Llama::Object::Util;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Exporter 'import';
our @EXPORT_OK = qw(add_abstract_method abstract_method);

sub add_abstract_method ($package, $name, $message = undef) {
  {
    no strict 'refs';
    *{$package . '::' . $name} = abstract_method($package, $name, $message);
  }
}

sub abstract_method ($package, $name, $message = undef) {
  $message //= "${package}::$name - abstract methods cannot be invoked";
  return sub { Carp::confess $message };
}

1;
