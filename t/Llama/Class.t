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

subtest 'eigen classes' => sub {
  package EigenTest {
    use Llama::Object qw(+HashObject :constructor);
  }

  my $object = EigenTest->new;
  isa_ok $object => 'EigenTest';

  my $eigen_class = $described_class->own($object);
  $eigen_class->add_method(translate => sub { 'eigen means own' });

  ok !(EigenTest->new->can('translate'));
  can_ok $object => 'translate';
  isa_ok $object => 'EigenTest';
  isa_ok $object => $eigen_class->name;
};

done_testing;
