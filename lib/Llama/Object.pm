package Llama::Object;
use strict;
use warnings;
use utf8;
use feature 'signatures';
no strict 'refs';

use Carp ();
use Module::Load ();
use Scalar::Util ();

use Llama::Object::Util qw(abstract_method);
use Llama::Delegation;
use Llama::Perl::Package;
use Llama::Util qw(extract_flags);

use overload 'bool' => sub{shift->Bool}, '""' => sub{shift->Str};

sub import($, @args) {
  my ($calling_package) = caller;
  my %flags = extract_flags \@args;
  my $package = Llama::Perl::Package->named($calling_package);

  my @parents = $flags{-base} ? (__PACKAGE__) : @args;
  Llama::Perl::Package->named($_)->maybe_load for @parents;
  push $package->ISA->@*, @parents;

  # disallow allocation for abstract classes
  if ($flags{-abstract}) {
    $package->add_sub('allocate', abstract_method(
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

sub allocate ($class) {
  Carp::confess "abstract classes cannot be allocated";
}

delegate {add_method => 'ADD_METHOD'} => 'OWN_CLASS';
delegate {methods => 'METHODS', attributes => 'ATTRIBUTES'} => 'CLASS';

sub ADD_ATTRIBUTE ($self, @args) {
  my $class     = $self->OWN_CLASS;
  my $attribute = $class->add_attribute(@args);
  my $name      = $attribute->name;

  if ($attribute->is_mutable) {
    $class->add_method($name => sub ($self, @args) {
      Carp::confess "attribute methods only work on instances" unless ref($self);
      if (@args) {
        $class->set_attribute_value($name, $args[0]);
        return $self;
      }
      return $class->get_attribute_value($name);
    });
  } else {
    $class->add_method($name => sub ($self) {
      Carp::confess "attribute methods only work on instances" unless ref($self);
      return $class->get_attribute_value($name);
    });
  }

  $self;
}

sub OWN_CLASS ($self) {
  return $self->CLASS unless Scalar::Util::blessed($self);
  return $self->CLASS if $self->CLASS->isa('Llama::EigenClass');

  Llama::Perl::Package
    ->named('Llama::Class')
    ->maybe_load
    ->name
    ->own($self)
}

sub CLASS ($self) {
  Llama::Perl::Package
    ->named('Llama::Class')
    ->maybe_load
    ->name
    ->named($self->CLASS_NAME)
}

sub CLASS_NAME ($self) { ref($self) || $self }

sub BLESS ($self, $class_name) {
  bless $self, $class_name;
  $self;
}

sub TYPE ($self) { Scalar::Util::reftype($self) }
sub ADDR ($self) { Scalar::Util::refaddr($self) }
*ID = \&ADDR;

sub same ($self, $other) { $self->ID eq $other->ID }

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

# # in Llama/Record.pm
# package Llama::Record;
# use Llama::Object 'Llama::HashObject', -constructor; # will import a default constructor
#
# sub BUILD ($self) {
#   # initialization within constructor
# }
#
# 1;
#
# # Meta Protocol
# Llama::Record->package->is_package # => 1
# Llama::Record->package->is_module # => 1
# Llama::Record->package # Llama::Perl::Module=HASH(0x097408)
# Llama::Record->module # Llama::Perl::Module=HASH(0x097408)
# Llama::Record->class # Llama::Class=HASH(0x018129)
#
# # will allocate but not call 'INIT'
# my $record_class = Llama::Record->allocate(
#   street_address_1 => 'Str',
#   street_address_2 => 'Optional[Str]',
#   city             => 'Str',
#   state            => 'Str',
#   postal           => 'Str'
#   notes            => 'Optional[Mutable[Str]]',
# );
#
# # will allocate and call 'INIT'
# my $record_class = Llama::Record->new(
#   street_address_1 => 'Str',
#   street_address_2 => 'Optional[Str]',
#   city             => 'Str',
#   state            => 'Str',
#   postal           => 'Str'
#   notes            => 'Optional[Mutable[Str]]',
# );
#
# $record_class # Llama::Class=Hash(0x018129) isa Llama::Object
#
# $record_class->instance_method_names # (to_hash, INIT, ...)
# $record_class->method_names # (new, allocate, ...)
# $record_class->name('Address');
#
# my $address = $record_class->new(
#   street_address_1 => '34 Orchard St.',
#   city             => 'Loring',
#   state            => 'PA',
#   postal           => 03982,
# ); => # Address=Hash(0x08422)
#
# $address->city # => Loring
# $address->{street_address_1} # => '34 Orchard St.'
# $address->{state} = 'NY' # => die! not 'Mutable'
# $address->{notes} = 'Wrong state'
# $new_address = $address->with(state => 'NY') # => Address=Hash(0x09210)
# $new_address->notes('Correct state') # => Address=Hash(0x09210)

1;
