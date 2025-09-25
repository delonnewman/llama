package Llama::Base::Util;

use strict;
use warnings;
use utf8;
use feature ':5.20';
use feature 'signatures';
no strict 'refs';

use Carp ();

sub add_abstract_method ($package, $name, $message = undef) {
  $message //= "${package}::$name - abstract methods cannot be invoked";
  $package->add_sub($name, sub { Carp::confess $message });
}

sub add_constructor ($package) {
  $package->add_sub('new', sub ($self, @args) {
    my $class = ref($self) || $self;
    my $object = $class->allocate(@args);

    $object->try('BUILD', @args);

    return $object;
  });
}

1;
