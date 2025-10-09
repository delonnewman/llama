package Llama::Base::Hash;
use Llama::Prelude qw(+Base :signatures);

use Data::Printer;
use Hash::Util ();

use Llama::Package;

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

sub HashRef ($self) {
  my $ref = $self->Hash;
  return $ref;
}

{
  no strict 'refs';
  *DATAFY = \&HashRef;
}

sub Hash ($self) {
  my %hash = map { $_ => $self->{$_} } grep { defined $self->{$_} } keys %$self;
  wantarray ? %hash : \%hash;
}

sub Array ($self) {
  my @array = $self->META->pairs;
  wantarray ? @array : \@array;
}

sub Str ($self) {
  my $class = $self->name;

  no strict 'refs';
  my %attributes = %{$class . '::ATTRIBUTES'};
  my $pairs = join ', ' => map { $_ . ' => ' . $attributes{$_}->type } keys %attributes;

  return $pairs ? "$class($pairs)" : $class;
}

1;
