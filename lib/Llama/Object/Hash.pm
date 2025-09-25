package Llama::Object::Hash;
use Llama::Base qw(+Object :signatures);

sub keys ($self) { keys $self->subject->%* }
sub values ($self) { values $self->subject->%* }

sub freeze ($self, @keys) {
  my @attributes = ($self->subject_keys, @keys);

  Hash::Util::lock_keys($self->subject->%*, @attributes);
  Hash::Util::lock_value($self->subject->%*, $_) for @attributes;

  $self;
}

sub is_frozen ($self) { Hash::Util::hash_locked(%$self) }

1;
