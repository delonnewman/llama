package Llama::HashObject;
use Llama::Base qw(:base :constructor :signatures);

use Hash::Util ();

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
