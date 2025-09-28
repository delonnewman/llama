package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);

sub BUILD ($self, %attributes) {
  $self->assign_attributes(%attributes);
}

sub freeze ($self, @keys) {
  my @attributes = $self->class->attributes;
  
  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for $self->class->readonly_attributes;

  $self;
}

my $AttributeValue = sub ($attribute, $value) {
  my $name    = $attribute->name;
  my $default = $attribute->default;

  $value = $default->() if $default && !defined($value);

  return $value;
};

sub assign_attributes ($self, @args) {
  return unless @args;

  my %attributes = @args > 1 ? @args : $args[0]->%*;
  for my $name ($self->class->attributes) {
    my $attribute = $self->class->attribute($name);
    my $value     = $AttributeValue->($attribute, $attributes{$name});
    if (defined $value) {
      $self->$name($value);
      next;
    }
    die "$name is required" if $attribute->is_required;
  }

  return $self;
}

sub HashRef ($self) {
  my $ref = $self->Hash;
  return $ref;
}

sub Hash ($self) {
  my %hash = (%$self);
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
