package Llama::Base::Hash::Test;
use Llama::Test::TestSuite;

use Llama::Util qw(hash_code);

my $described_class = 'Llama::Base::Hash';
require_ok $described_class;

package BaseHashTestClass {
  use Llama::Prelude qw(+Base::Hash);
}

subtest 'hashing and value equality basics' => sub {
  my $subject = BaseHashTestClass->new(name => 'Paul', email => 'paul@example.com');
  my $second  = BaseHashTestClass->new(name => 'Paul', email => 'paul@example.com');
  my $third   = BaseHashTestClass->new(email => 'paul@example.com', name => 'Paul');

  is $subject->__hash__ => $second->__hash__;
  is $subject->__hash__ => $third->__hash__;
  isnt $subject->__id__ => $second->__id__;

  ok $subject->equals($second);
};

done_testing;
