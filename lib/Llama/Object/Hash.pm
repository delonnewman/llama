package Llama::Object::Hash;
use Llama::Prelude qw(+Object :signatures);

use Llama::Pair;

sub keys ($self) {
  my @keys = CORE::keys $self->subject->%*;
  wantarray ? @keys : \@keys;
}

sub values ($self) {
  my @values = CORE::values $self->subject->%*;
  wantarray ? @values : \@values;
}

sub pairs  ($self) {
  my $subject = $self->subject;
  my @keys    = $self->keys;
  my @pairs   = map { Llama::Pair->new($_ => $subject->{$_}) } @keys;
  wantarray ? @pairs : \@pairs;
}

sub is_frozen ($self) { Hash::Util::hash_locked($self->subject->%*) }

sub unfreeze ($self) {
  $self->unseal;
  my $subject = $self->subject;
  Hash::Util::unlock_value(%$subject, $_) for $self->class->readonly_attributes;

  return $self;
}

sub freeze ($self) {
  $self->seal;
  my $subject = $self->subject;
  Hash::Util::lock_value(%$subject, $_) for $self->class->readonly_attributes;

  return $self;
}

sub is_sealed ($self) { Hash::Util::hash_locked(%$self) }

sub seal ($self) {
  my @attributes = ($self->class->attributes, $self->keys, '__hash__');
  my $subject = $self->subject;
  Hash::Util::lock_keys(%$subject, @attributes);
  return $self;
}

sub unseal ($self) {
  Hash::Util::unlock_keys(%$self);
}

1;
