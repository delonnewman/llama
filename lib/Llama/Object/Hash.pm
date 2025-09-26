package Llama::Object::Hash;
use Llama::Base qw(+Object :signatures);

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

sub freeze ($self, @keys) {
  my @attributes = ($self->subject_keys, @keys);

  Hash::Util::lock_keys($self->subject->%*, @attributes);
  Hash::Util::lock_value($self->subject->%*, $_) for @attributes;

  $self;
}

sub is_frozen ($self) { Hash::Util::hash_locked(%$self) }

1;
