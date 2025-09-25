package Llama::Base;
use strict;
use warnings;
use utf8;
use feature 'signatures';
no strict 'refs';

use Carp ();
use Data::Printer;
use Module::Load ();
use Scalar::Util ();

use Llama::Object::Util qw(abstract_method);
use Llama::Perl::Package;
use Llama::Util qw(extract_flags);

use overload
  'bool' => sub{shift->Bool},
  '""' => sub{shift->Str};

sub import($, @args) {
  my ($calling_package) = caller;
  my %flags = extract_flags \@args;
  my $package = Llama::Perl::Package->named($calling_package);

  my @parents = $flags{-base} ? (__PACKAGE__) : @args;
  Llama::Perl::Package->named($_)->maybe_load for @parents;
  push $package->ISA->@*, @parents;

  # disallow allocation for abstract classes
  if ($flags{-abstract}) {
    $package->add_sub('new', abstract_method(
      $calling_package,
      'allocate',
      'abstract classes cannot be allocated'
    ));
  }

  # create default constructor
  if ($flags{-constructor}) {
    $package->add_sub('new', sub ($class, @args) {
      $class = ref($class) || $class;
      my $object = $class->allocate;
      $object->try('BUILD', @args);
      return $object;
    });
  }
}

sub allocate ($self) { die "not implemented" }

sub CLASS ($self) {
  my $class_name = ref($self) || $self;

  Llama::Perl::Package
    ->named('Llama::Class')
    ->maybe_load
    ->name
    ->named($class_name);
}

sub __type__ ($self) { Scalar::Util::reftype($self) }
sub __addr__ ($self) { Scalar::Util::refaddr($self) }
*__id__ = \&__addr__;

sub is_same ($self, $other) { $self->__id__ eq $other->__id__ }
*is_equal = \&is_same;
*is_match = \&is_same;

sub Bool { 1 }

sub Str ($self) {
  my $class = $self->CLASS_NAME;
  my $id = sprintf("0x%06X", $self->ID);

  "$class=OBJECT($id)";
}

sub try ($self, $method_name, @args) {
  if (my $method = $self->can($method_name)) {
    return $self->$method(@args);
  }
}

sub then ($self, $sub_or_method_name, @args) {
  return $self->$sub_or_method_name(@args);
}

sub tap ($self, $sub_or_method_name, @args) {
  $self->$sub_or_method_name(@args);
  return $self;
}

1;

__END__

# in Llama/Record.pm
package Llama::Record;
use Llama::Base '+HashClass', -signatures;

sub new ($self, %attributes) {
  my $class = $self->SUPER::new($attributes{name}); # if name is undef will be an instance of AnonymousClass

  my %schema = ($attributes{attributes} // {})->%*;
  for my $attribute (keys %schema) {
    $class->add_attribute($attribute, $schema{$attribute});
  }

  $class->add_method('new', sub ($self, %attributes) {
    $self->HOW->attributes->validate(\%attributes);
  });

  return $class;
}

1;

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
    street_address_1 => 'Str',
    street_address_2 => 'Optional[Str]',
    city             => 'Str',
    state            => 'Str',
    postal           => 'Str'
    notes            => 'Optional[Mutable[Str]]',
  }
);

# will allocate and call 'BUILD'
my $record_class = Llama::Record->new(
  name       => 'Address', # if unnamed will be an instance of AnonymousClass
  attributes => {
    street_address_1 => 'Str',
    street_address_2 => 'Optional[Str]',
    city             => 'Str',
    state            => 'Str',
    postal           => 'Str'
    notes            => 'Optional[Mutable[Str]]',
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
