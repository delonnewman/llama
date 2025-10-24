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

subtest 'hashing and equality regressions' => sub {
  my $subject = BaseHashTestClass->new(content => '/uploads/img_31PXmBA2negA3iU0CwB1h.jpeg', id => '019a173d-b7b6-7f88-a3cf-982c31208b23', name => "");
  my $second  = BaseHashTestClass->new(content => '/uploads/img_31PXnjl818sP83E8qHSYn.jpeg', id => '019a173e-a7b6-7ba6-85aa-144a1257d842', name => "");
  my $third   = BaseHashTestClass->new(content => '/uploads/img_31PXotG8ITRiAijyDDVHR.jpeg', id => '019a173f-5957-7487-842d-ea8c8bb2e1ee', name => "");

  isnt $subject->__hash__ => $second->__hash__;
  isnt $subject->__hash__ => $third->__hash__;
  isnt $second->__hash__  => $third->__hash__;
};

done_testing;
