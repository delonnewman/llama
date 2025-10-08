package Llama::Base::Hash;
use Llama::Prelude qw(+Base :signatures);

use Data::Printer;
use Hash::Util ();

use Llama::Package;

sub allocate ($class, @args) {
  bless {}, $class;
}

# TODO: remove
sub BUILD ($self, @args) {
  if (!@args && (my @required = $self->class->required_attributes)) {
    die "ArgumentError: missing required attribute(s): " . join(', ' => @required);
  }
  $self->parse(@args);
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

# sub class ($self) {
#   my $pkg = __PACKAGE__;
#   return Llama::Class->named($pkg) if ref $self eq $pkg;
#   return Llama::Package->named('Llama::Class::Hash')->maybe_load->name->named($self->__name__);
# }

sub META ($self) {
  return $self->class unless ref $self;
  # TODO: override 'instance'
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

# TODO: move to Record
sub Str ($self) {
  my $class = $self->__name__;

  my @pairs = $self->META->pairs;
  return $class unless @pairs;

  my $pairs = join ', ' => map { $_->key . ' => ' . $_->value } grep { $_->value } @pairs;
  return "$class($pairs)";
}

1;
