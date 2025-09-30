package Llama::Base;

use strict;
use warnings;
use utf8;
use feature ':5.20';
use feature 'signatures';
no warnings 'experimental::signatures';
use mro;
no strict 'refs';

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Package;
use Llama::Util qw(extract_flags);
use Llama::Base::Util;

use overload
  'bool' => sub{shift->Bool},
  '""'   => sub{shift->Str};

sub import($, @args) {
  # sensible defaults
  $_->import for qw(strict warnings utf8);
  feature->import(':5.20');

  my %flags = extract_flags \@args;
  return unless %flags;

  my $caller = caller;
  my $pkg    = Llama::Package->named($caller);

  # subclassing
  my @parents = $flags{-base} ? (__PACKAGE__) : @args;
  if (@parents) {
    Llama::Package->named($_)->maybe_load for @parents;
    $pkg->ISA(@parents);
  }

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

  # enable signatures
  if ($flags{-signatures}) {
    Carp::croak 'Subroutine signatures require Perl 5.20+' if $] < 5.020;
    require experimental;
    experimental->import($_) for qw(signatures postderef);
  }
}

# Protect subclasses using AUTOLOAD
sub DESTROY { }

sub new ($self, @args) {
  my $class = ref($self) || $self;
  my $object = $class->allocate(@args);

  $object->try('BUILD', @args);

  return $object;
}

sub META ($self) {
  return $self->class unless ref $self;
  return Llama::Package->named('Llama::Object')->maybe_load->name->new($self);
}

sub class ($self) {
  Llama::Package->named('Llama::Class')->maybe_load->name->named($self->__name__);
}

sub __name__ ($self) { ref($self) || $self }
sub __type__ ($self) { Scalar::Util::reftype($self) }
sub __addr__ ($self) { Scalar::Util::refaddr($self) }
*__id__ = \&__addr__;

sub identical ($self, $other) { $self->__id__ eq $other->__id__ }
*equals  = \&identical;
*matches = \&identical;

sub Bool { 1 }

sub Str ($self) {
  my $class = $self->__name__;
  my $id = sprintf("0x%06X", $self->__id__);

  return "$class=OBJECT($id)";
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

sub itself ($self, @args) { $self }

*if_null   = \&itself;
*if_falsy  = \&itself;
*if_truthy = \&tap;

sub if ($self, @args) { $self->if_truthy(@args) }
sub else ($self, @args) { $self->if_falsy(@args) }

sub method ($self, $name)  {
  return sub (@args) { $self->$name(@args) };
}

1;

