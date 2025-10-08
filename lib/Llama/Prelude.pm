package Llama::Prelude;

use strict;
use warnings;
use utf8;
use feature ':5.20';
use experimental 'signatures';

use Carp ();
use Data::Printer;
use Scalar::Util ();

use Llama::Package;
use Llama::Util qw(extract_flags);

sub import($, @args) {
  my %flags = extract_flags \@args;
  return unless @args || %flags;

  # sensible defaults
  $_->import for qw(strict warnings utf8);
  feature->import(':5.20');

  my $caller = caller;
  my $pkg    = Llama::Package->named($caller);

  # subclassing
  my @parents = @args;
  if (@parents) {
    Llama::Package->named($_)->maybe_load for @parents;
    $pkg->ISA(@parents);
  }

  # enable signatures
  if ($flags{-signatures}) {
    experimental->import($_) for qw(signatures postderef);
  }
}

my $add_abstract_method = sub ($package, $name, $message = undef) {
  $message //= "${package}::$name - abstract methods cannot be invoked";
  $package->add_sub($name, sub { Carp::confess $message });
};

1;
