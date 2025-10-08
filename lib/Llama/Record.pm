package Llama::Record;
use Llama::Prelude qw(+Item :signatures);

use Data::Printer;
use Hash::Util ();
use Scalar::Util ();

use Llama::Class::Record;

sub import ($class, $attributes = undef) {
  my $caller = caller;
  if ($attributes) {
    $class->new_class(name => $caller, attributes => $attributes);
  }
}

sub new_class ($class, %attributes) {
  my $self = Llama::Class::Record->new($attributes{name} // die "name is required");
  $self->superclasses($class);

  my %schema = ($attributes{attributes} // {})->%*;
  for my $attribute (keys %schema) {
    $self->add_attribute($attribute, $schema{$attribute});
  }

  return $self;
}

sub BUILD ($self, @args) {
  $self->next::method(@args);
  $self->freeze;
}

sub __kind__ { 'Llama::Class::Record' }

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
use Llama::Prelude qw(+Class :signatures);

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
