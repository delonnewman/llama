package Llama::Object;
use strict;
use warnings;
use utf8;
use feature 'signatures';

sub import {  }

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
