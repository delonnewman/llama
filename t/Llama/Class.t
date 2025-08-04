package Llama::Perl::Package::Test;
use strict;
use warnings;
use utf8;

use Test::More;
use lib qw(../../lib);

use Llama::Class;

subtest 'caching' => sub {
  my $first = Llama::Class->named('Testing');
  my $second = Llama::Class->named('Testing');

  is $first->ADDR => $second->ADDR;
};

done_testing;
