package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);

sub BUILD ($self, @args) {
  if (!@args && (my $required = $self->class->required_attributes)) {
    die "ArgumentError: missing required attribute(s): " . join(', ' => @$required);
  }
  $self->parse(@args);
}

sub freeze ($self, @keys) {
  my @attributes = $self->class->attributes;
  
  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for $self->class->readonly_attributes;

  $self;
}

sub HashRef ($self) {
  my $ref = $self->Hash;
  return $ref;
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
  my $class = $self->__name__;
  my $pairs = join ', ' => map { $_->key . ' => ' . $_->value } grep { $_->value } $self->META->pairs;

  return "$class($pairs)";
}

1;
