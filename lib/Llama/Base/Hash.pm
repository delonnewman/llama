package Llama::Base::Hash;
use Llama::Prelude qw(+Base :signatures);
no strict 'refs';

use Data::Printer;
use Hash::Util ();
use Scalar::Util qw(blessed);

use Llama::Package;
use Llama::Util qw(string_hash hash_combine);

sub allocate ($class) {
  bless {}, $class;
}

sub BUILD ($self, %args) {
  %{$self} = %args;
}

sub clone ($self) {
  my $copy = $self->allocate;
  %{$copy} = %{$self};
  return $copy;
}


sub __kind__ { 'Llama::Class::Hash' }

sub instance ($self) {
  return Llama::Package->named('Llama::Object::Hash')->maybe_load->name->new($self);
}

sub __hash__ ($self) {
  my $hash;
  $hash = !$hash
    ? hash_combine(string_hash($_), string_hash($self->{$_}))
    : hash_combine($hash, hash_combine(string_hash($_), string_hash($self->{$_}))) for sort keys %$self;
  return $hash;
}

sub equals ($self, $other) {
  return !!0 unless blessed($other) && $other->isa(__PACKAGE__);
  return $self->__hash__ eq $other->__hash__;
}

sub toHashRef ($self) {
  my $ref = $self->toHash;
  return $ref;
}

*DATAFY = \&toHashRef;

sub toHash ($self) {
  my %hash =
    map { $_ => $self->{$_} }
    grep { defined $self->{$_} } $self->instance->keys;
  wantarray ? %hash : \%hash;
}

sub toArray ($self) {
  my @array = $self->instance->pairs;
  wantarray ? @array : \@array;
}

sub toStr ($self) {
  my $class = $self->__name__;
  my $pairs =
    join ', ' => map { $_->name . ' => ' . $_->type } $self->class->ATTRIBUTES;

  return $pairs ? "$class($pairs)" : $class;
}

1;
