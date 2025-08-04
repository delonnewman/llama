package Llama::Perl::Package::Test;
use strict;
use warnings;
use utf8;

use Test::More;
use lib qw(../../lib);

use Llama::Class;
my $described_class = 'Llama::Class';

subtest 'basics' => sub {
  my $named = $described_class->new('Basics');
  is $named->name => 'Basics';
  is $named->mro => 'c3';

  my $anon = $described_class->new;
  isa_ok $anon, 'Llama::Class::AnonymousClass';
};

subtest 'caching' => sub {
  my $first = $described_class->named('Testing');
  my $second = $described_class->named('Testing');

  is $first->ADDR => $second->ADDR;
};

done_testing;
