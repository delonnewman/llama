package Llama::Class::InstanceCache;
use strict;
use warnings;
use utf8;
use feature 'signatures';
no strict 'refs';

sub KEY :prototype() { '__META_CLASS__' }

sub get ($class_name) {
  my $sym = $class_name . '::' . KEY;
  ${$sym};
}

sub set ($class_name, $instance) {
  my $sym = $class_name . '::' . KEY;
  ${$sym} = $instance;
  $instance;
}


1;
