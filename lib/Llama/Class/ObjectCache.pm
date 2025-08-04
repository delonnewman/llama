package Llama::Class::ObjectCache;
use strict;
use warnings;
use utf8;
use feature 'signatures';
no strict 'refs';

use constant META_CLASS => '__META_CLASS__';

sub get ($class_name) {
  my $sym = $class_name . '::' . META_CLASS;
  ${$sym};
}

sub set ($class_name, $instance) {
  my $sym = $class_name . '::' . META_CLASS;
  ${$sym} = $instance;
  $instance;
}


1;
