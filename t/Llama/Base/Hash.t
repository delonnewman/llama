package Llama::Base::Hash::Test;
use Llama::Test::TestSuite;

use Llama::Util qw(hash_code);

my $described_class = 'Llama::Base::Hash';
require_ok $described_class;

package BaseHashTestClass {
  use Llama::Prelude qw(+Base::Hash);
}

my $subject = BaseHashTestClass->new(name => 1);
my $second = BaseHashTestClass->new(name => 1);

is $subject->__hash__ => $second->__hash__;
isnt $subject->__id__ => $second->__id__;

ok $subject->equals($second);

done_testing;
