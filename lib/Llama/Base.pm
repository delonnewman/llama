package Llama::Base;

use strict;
use warnings;
use utf8;
use feature ':5.20';
use feature 'signatures';
use mro;
no strict 'refs';

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Base::Util;
use Llama::Perl::Package;
use Llama::Util qw(extract_flags);

use overload
  'bool' => sub{shift->Bool},
  '""'   => sub{shift->Str};

sub Package :prototype() { 'Llama::Perl::Package' }

sub import($, @args) {
  # sensible defaults
  $_->import for qw(strict warnings utf8);
  feature->import(':5.20');

  my %flags = extract_flags \@args;
  return unless %flags;

  my $caller = caller;
  my $pkg    = Package->named($caller);


  # subclassing
  my @parents = $flags{-base} ? (__PACKAGE__) : @args;
  Package->named($_)->maybe_load for @parents;
  $pkg->ISA(@parents);

  # disallow allocation for abstract classes
  if ($flags{-abstract}) {
    my $add_abstract_method = \&Llama::Base::Util::add_abstract_method;
    $pkg->$add_abstract_method('allocate', 'abstract classes cannot be allocated');
  }

  # create default constructor
  if ($flags{-constructor}) {
    my $add_constructor = \&Llama::Base::Util::add_constructor;
    $pkg->$add_constructor();
  }

  if ($flags{-signatures}) {
    Carp::croak 'Subroutine signatures require Perl 5.20+' if $] < 5.020;
    require experimental;
    experimental->import($_) for qw(signatures postderef);
  }
}

# Protect subclasses using AUTOLOAD
sub DESTROY { }

sub allocate ($class) { die "not implemented" }

sub HOW ($self) {
  return Package->named('Llama::Class')->maybe_load->name->named($self) unless ref $self;
  return Package->named('Llama::Object')->maybe_load->name->new($self);
}

sub __type__ ($self) { Scalar::Util::reftype($self) }
sub __addr__ ($self) { Scalar::Util::refaddr($self) }
*__id__ = \&__addr__;

sub identical ($self, $other) { $self->__id__ eq $other->__id__ }
*equals  = \&identical;
*matches = \&identical;

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

sub itself ($self) { $self }

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
