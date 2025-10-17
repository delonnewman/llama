package Llama::Base::Hash;
use Llama::Prelude qw(+Base :signatures);

use Data::Printer;
use Hash::Util ();
use Scalar::Util qw(blessed);

use Llama::Package;
use Llama::Util qw(string_hash hash_combine);

sub allocate ($class, @args) {
  bless {}, $class;
}

sub is_frozen ($self) { Hash::Util::hash_locked(%$self) }

sub unfreeze ($self) {
  Hash::Util::unlock_keys(%$self);
  Hash::Util::unlock_value(%$self, $_) for $self->class->readonly_attributes;

  return $self;
}

sub freeze ($self) {
  my @attributes = $self->class->attributes;
  
  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for $self->class->readonly_attributes;

  return $self;
}

sub __kind__ { 'Llama::Class::Hash' }

sub instance ($self) {
  return Llama::Package->named('Llama::Object::Hash')->maybe_load->name->new($self);
}

sub __hash__ ($self) {
  $self->{__hash__} //= do {
    my $hash;
    $hash = !$hash
      ? hash_combine(string_hash($_), string_hash($self->{$_}))
      : hash_combine($hash, hash_combine(string_hash($_), string_hash($self->{$_}))) for keys %$self;
    $hash;
  };
}

sub equals ($self, $other) {
  return !!0 unless blessed($other) && $other->isa(__PACKAGE__);
  return $self->__hash__ eq $other->__hash__;
}

sub toHashRef ($self) {
  my $ref = $self->toHash;
  return $ref;
}

{
  no strict 'refs';
  *DATAFY = \&toHashRef;
}

sub toHash ($self) {
  my %hash = map { $_ => $self->{$_} } grep { defined $self->{$_} } keys %$self;
  wantarray ? %hash : \%hash;
}

sub toArray ($self) {
  my @array = $self->META->pairs;
  wantarray ? @array : \@array;
}

sub toStr ($self) {
  my $class = $self->name;

  no strict 'refs';
  my %attributes = %{$class . '::ATTRIBUTES'};
  my $pairs = join ', ' => map { $_ . ' => ' . $attributes{$_}->type } keys %attributes;

  return $pairs ? "$class($pairs)" : $class;
}

1;
