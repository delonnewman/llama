package Llama::Class::InstanceCache;

use strict;
use warnings;
use utf8;
use experimental 'signatures';
no strict 'refs';

sub KEY :prototype() { '__META_CLASS__' }

sub get ($, $class_name) {
  my $sym = $class_name . '::' . KEY;
  return ${$sym};
}

sub set ($, $class_name, $instance) {
  my $sym = $class_name . '::' . KEY;
  ${$sym} = $instance;
  return $instance;
}

sub invalidate ($class, $class_name) {
  $class->set($class_name, undef);
  return $class;
}

1;
