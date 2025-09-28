package Llama::Record;
use Llama::Base qw(+Entity :signatures);

use Llama::Record::Class;

no warnings 'experimental::signatures';

sub import ($class, $attributes = undef) {
  if ($attributes) {
    my $caller = caller;
    Llama::Record::Class->create(name => $caller, attributes => $attributes);
  }
}

sub class ($self) {
  my $pkg = __PACKAGE__;
  return Llama::Class->named($pkg) if ref $self eq $pkg;
  return Llama::Record::Class->named($self->__name__);
}

sub assign_attributes ($self, @args) {
  return unless @args;

  my %attributes = @args > 1 ? @args : $args[0]->%*;
  $self->$_($attributes{$_} // die "$_ is required") for $self->class->required_attributes;
  for ($self->class->optional_attributes) {
    $self->$_($attributes{$_}) if $attributes{$_};
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

__END__

package Person;
use Llama::Record {
 name  => 'Str',
 dob   => 'DateTime', # will attempt to load if it's not already
 email => 'EmailAddress',
 phone => 'PhoneNumber',
};

Llama::AttributeType->add('PhoneNumber', sub { shift =~ /(\d{3}) \d{3}-\d{4}/ });
Llama::AttributeType->add('EmailAddress', sub { shift =~ /@/ });

sub age ($self) {
  # ...calculate age with $self->dob
}

Llama::Package->named('DateTime')->is_loaded


# in Llama/Record.pm
package Llama::Record;
use Llama::Base '+Class', -signatures;

sub new ($self, %attributes) {
  my $class = $self->SUPER::new($attributes{name}); # if name is undef will be an instance of AnonymousClass
  $class->superclasses('Llama::Base::Hash');

  my %schema = ($attributes{attributes} // {})->%*;
  for my $attribute (keys %schema) {
    $class->add_attribute($attribute, $schema{$attribute});
  }

  $class->add_method('BUILD', sub ($self, %attributes) {
    $self->class->attributes->parse(\%attributes, $self);
    $self->freeze;
  });

  return $class;
}

package main;
use Llama::Attribute::Type qw(Str Optional Mutable);

# Meta Protocol
Llama::Record->HOW->package->is_package # => 1
Llama::Record->HOW->package->is_module # => 1
Llama::Record->HOW->package # Llama::Package=SCALAR(0x097408)
Llama::Record->HOW->module # Llama::Package=SCALAR(0x097408)
Llama::Record->HOW # Llama::Class=SCALAR(0x018129)

# will allocate but not call 'BUILD'
my $record_class = Llama::Record->allocate(
  name       => 'Address',
  attributes => {
    street_address_1 => Str,
    street_address_2 => Optional(Str),
    city             => Str,
    state            => Str,
    postal           => Str
    notes            => Optional(Mutable(Str)),
  }
);

# will allocate and call 'BUILD'
my $record_class = Llama::Record->new(
  name       => 'Address', # if unnamed will be an instance of AnonymousClass
  attributes => {
    street_address_1 => Str,
    street_address_2 => Optional(Str),
    city             => Str,
    state            => Str,
    postal           => Str
    notes            => Optional(Mutable(Str)),
  }
);

$record_class # Llama::Class=SCALAR(0x018129) isa Llama::Base
$record_class->instance_method_names # (Str, HashRef, BUILD, ...), instance methods from HashObject or inheriting package when named
$record_class->method_names # (new, allocate, ...)

my $address = $record_class->new(
  street_address_1 => '34 Orchard St.',
  city             => 'Loring',
  state            => 'PA',
  postal           => 03982,
); => # Address=HASH(0x08422)

$address->city # => Loring
$address->{street_address_1} # => '34 Orchard St.'
$address->{state} = 'NY' # => die! not 'Mutable'
$address->{notes} = 'Wrong state'
$new_address = $address->with(state => 'NY') # => Address=Hash(0x09210)
$new_address->notes('Correct state') # => Address=Hash(0x09210)
