package Llama::Test::TestSuite;

use utf8;
use strict;
use warnings;
use feature ':5.20';
use feature 'signatures';

use Data::Printer ();
use Test::More ();

my @EXPORT = qw();
my %FORWARDING = (
  'Test::More' =>
    [qw(ok is isnt pass fail diag subtest is_deeply like unlike done_testing require_ok isa_ok can_ok)],
  'Data::Printer' => [qw(p np)],
);

sub import {
  $_->import for qw(strict warnings utf8);
  feature->import(':5.24', 'signatures');

  {
    my ($calling_package) = caller;
    no strict 'refs';

    # export symbols in @EXPORT
    for my $symbol (@EXPORT) {
      *{$calling_package . '::' . $symbol} = *{$symbol};
    }

    # export symbols that forward to modules in @FORWARDING
    for my $module (keys %FORWARDING) {
      for my $symbol ($FORWARDING{$module}->@*) {
        *{$calling_package . '::' . $symbol} = *{ $module . '::' . $symbol};
      }
    }
  }
}

1;
