package Llama::Object;
use strict;
use warnings;
use utf8;
use feature 'signatures';
use feature 'state';

use Carp ();
use Module::Load ();

use Llama::Perl::Package;
use Llama::Util qw(extract_flags);

use overload 'bool' => sub{1};

sub import($class, @args) {
  my ($calling_package) = caller;
  my %flags = extract_flags \@args;
  mro::set_mro($calling_package, 'c3') unless $calling_package eq 'main';

  {
    no strict 'refs';

    my @parents = $flags{-base} ? (__PACKAGE__) : @args;
    Module::Load::load($_) for @parents;
    push @{$calling_package . '::ISA'}, @parents;

    # disallow allocation for abstract classes
    if ($flags{-abstract}) {
      *{$calling_package . '::allocate'} = sub ($class) {
        Carp::confess "abstract classes cannot be allocated";
      };
    }

    # create default constructor
    if ($flags{-constructor}) {
      *{$calling_package . '::new'} = sub ($class, @args) {
        my $object = $class->allocate(@args);
        if (my $method = $object->can('INIT')) {
          $object->$method(@args);
        }
        return $object;
      };
    }
  }
}

sub allocate ($class) {
  Carp::confess "abstract classes cannot be allocated";
}

sub class_name ($self) {
  my $class = ref($self);
  Carp::confess "invalid usage, called instance method on class"
    unless $class;

  $class;
}

sub class ($self) {
  my $pkg = Llama::Perl::Package->new('Llama::Class');
  $pkg->load unless $pkg->is_loaded;
  $pkg->name->new($self->class_name);
}

sub allocate { Carp::confess "allocate must be implemented by subclasses" }

state $current_id_ref = 0;
sub OBJECT_ID ($class) {
  my $pkg = __PACKAGE__;
  Carp::confess "invalid usage try $pkg->OBJECT_ID" unless $class eq $pkg;

  $current_id_ref++;
}

# # in Llama/Record.pm
# package Llama::Record;
# use Llama::Object 'Llama::HashObject', -constructor; # will import a default constructor
#
# sub INIT ($self) {
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
