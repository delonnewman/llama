package Llama::Base::Hash;
use Llama::Base qw(:base :constructor :signatures);

use Data::Printer;
use Hash::Util ();

use Llama::Package;

sub allocate ($class, @args) {
  bless {}, $class;
}

sub is_frozen ($self) { Hash::Util::hash_locked(%$self) }

sub freeze ($self) {
  my @attributes = $self->class->attributes;
  
  Hash::Util::lock_keys(%$self, @attributes);
  Hash::Util::lock_value(%$self, $_) for $self->class->readonly_attributes;

  $self;
}

sub class ($self) {
  my $pkg = __PACKAGE__;
  return Llama::Class->named($pkg) if ref $self eq $pkg;
  return Llama::Package->named('Llama::Class::Hash')->maybe_load->name->named($self->__name__);
}

sub META ($self) {
  return $self->class unless ref $self;
  return Llama::Package->named('Llama::Object::Hash')->maybe_load->name->new($self);
}

my $AttributeValue = sub ($self, $attribute, $value) {
  my $name    = $attribute->name;
  my $default = $attribute->default;

  $value = $self->$default() if $default && !defined($value);

  return $value;
};

sub parse ($self, @args) {
  die "ParseError: cannot parse empty value" unless @args;
  $self = $self->new unless ref $self;

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
  my $class = $self->__name__;
  my $pairs = join ', ' => map { $_->key . ' => ' . $_->value } grep { $_->value } $self->META->pairs;

  return "$class($pairs)";
}

1;
