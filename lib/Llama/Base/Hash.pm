package Llama::Base::Hash;
use Llama::Base qw(:base :constructor :signatures);

use Hash::Util ();

use Llama::Package;
sub Package :prototype() { 'Llama::Package' }

use overload '%{}' => sub{shift->HashRef};

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

sub assign_attributes ($self, @args) {
  return unless @args;

  my %attributes = @args > 1 ? @args : $args[0]->%*;
  $self->$_($attributes{$_}) for $self->class->attributes;

  return $self;
}

sub META ($self) {
  return $self->class unless ref $self;
  return Package->named('Llama::Object::Hash')->maybe_load->name->new($self);
}

sub HashRef ($self) { $self }

1;
