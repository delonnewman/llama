package Llama::Base::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Base';
require_ok $described_class;

package TestClass {
  use Llama::Prelude qw(+Base);
  sub allocate { bless {}, $_[0] }
}

my $subject = TestClass->new;

is $subject->__hash__ => $subject->__addr__;
is $subject->__id__ => $subject->__addr__;

done_testing;
