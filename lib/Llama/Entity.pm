package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);

sub BUILD ($self, @args) {
  if (!@args && (my $required = $self->class->required_attributes)) {
    die "ArgumentError: missing required attributes: " . join(', ' => @$required);
  }
  $self->assign_attributes(@args);
  $self->freeze;
}

sub freeze ($self, @keys) {
  my @attributes = $self->class->attributes;
  
  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for $self->class->readonly_attributes;

  $self;
}

my $AttributeValue = sub ($self, $attribute, $value) {
  my $name    = $attribute->name;
  my $default = $attribute->default;

  $value = $self->$default() if $default && !defined($value);

  return $value;
};

sub assign_attributes ($self, @args) {
  return unless @args;

  my %attributes = @args > 1 ? @args : $args[0]->%*;
  for my $name ($self->class->attributes) {
    my $attribute = $self->class->attribute($name);
    my $value     = $AttributeValue->($self, $attribute, $attributes{$name});
    if (defined $value) {
      $self->$name($value);
      next;
    }
    die "$name is required" if $attribute->is_required;
  }

  return $self;
}

sub with ($self, %attributes) {
  my %args = ($self->Hash, %attributes);
  return $self->new(%args);
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
