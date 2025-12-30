package Llama::Test::TestSuite;

use utf8;
use strict;
use warnings;
use feature ':5.20';
use experimental qw(signatures postderef);

use Data::Printer ();
use Test::More ();

my @EXPORT = qw(throws doesnt_throw);
my %FORWARDING = (
  'Test::More' =>
    [qw(ok is isnt pass fail diag subtest is_deeply like unlike done_testing require_ok isa_ok can_ok skip)],
  'Data::Printer' => [qw(p np)],
);

sub import {
  $_->import for qw(strict warnings utf8);
  feature->import(':5.20');
  experimental->import($_) for qw(signatures postderef);

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

sub throws :prototype(&@) {
  my ($block, $error_pattern) = @_;
  eval {
    $block->();
  };
  if ($@) {
    Test::More::fail("wrong exception thrown: $@") if $error_pattern && $@ !~ $error_pattern;
    Test::More::pass("exception thrown: $@");
  } else {
    Test::More::fail('no exception thrown');
  }
}

sub doesnt_throw :prototype(&@) {
  my ($block, $error_pattern) = @_;
  eval {
    $block->();
  };
  if ($@) {
    Test::More::fail("wrong exception thrown: $@") if $error_pattern && $@ !~ $error_pattern;
    Test::More::fail("exception thrown: $@");
  } else {
    Test::More::pass('no exception thrown');
  }
}

1;
