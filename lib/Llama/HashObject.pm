package Llama::HashObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Hash::Util ();

use Llama::Base qw(:base :constructor);

use overload '%{}' => sub{shift->HashRef};

sub allocate ($class, @args) {
  bless {}, $class;
}

sub lock ($self, @keys) {
  my @attributes = (keys %$self, @keys);

  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for @attributes;

  $self;
}

sub is_locked ($self) { Hash::Util::hash_locked(%$self) }

sub HashRef ($self) { $self }

1;
