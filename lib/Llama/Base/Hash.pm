package Llama::Base::Hash;
use Llama::Base qw(:base :constructor :signatures);

use Hash::Util ();

use Llama::Package;

sub allocate ($class, @args) {
  bless {}, $class;
}

sub is_frozen ($self) { Hash::Util::hash_locked(%$self) }

sub freeze ($self, @keys) {
  my @attributes = (keys %$self, @keys);

  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for @attributes;

  $self;
}

sub META ($self) {
  return $self->class unless ref $self;
  return Llama::Package->named('Llama::Object::Hash')->maybe_load->name->new($self);
}

1;
