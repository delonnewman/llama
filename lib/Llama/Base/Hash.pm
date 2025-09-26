package Llama::Base::Hash;
use Llama::Base qw(:base :constructor :signatures);

use Hash::Util ();

use Llama::Package;
sub Package :prototype() { 'Llama::Package' }

use overload '%{}' => sub{shift->HashRef};

sub allocate ($class, @args) {
  bless {}, $class;
}

sub freeze ($self, @keys) {
  my @attributes = (keys %$self, @keys);

  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for @attributes;

  $self;
}

# TODO: add 'assign_attributes', 'attribute_writer_missing'?

sub HOW ($self) {
  return Package->named('Llama::Class')->maybe_load->name->named($self) unless ref $self;
  return Package->named('Llama::Object::Hash')->maybe_load->name->new($self);
}

sub is_frozen ($self) { Hash::Util::hash_locked(%$self) }

sub HashRef ($self) { $self }

1;
