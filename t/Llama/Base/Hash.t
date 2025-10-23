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

  # They're each unique objects
  isnt $subject->__id__ => $second->__id__;
  isnt $subject->__id__ => $third->__id__;
  isnt $second->__id__ => $third->__id__;

  # They all have the same hash
  is $subject->__hash__ => $second->__hash__;
  is $subject->__hash__ => $third->__hash__;

  # So they are all 'equal'
  ok $subject->equals($second);
  ok $subject->equals($third);
};

done_testing;
