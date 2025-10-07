package Llama::Union::Test;
use Llama::Test::TestSuite;

use Feature::Compat::Try;

no strict 'refs';
no warnings 'experimental::signatures';

package TrafficLight { use Llama::Union qw(Red Yellow Green) }

my $described_class = 'Llama::Union';
my $subject = 'TrafficLight';

subtest 'accessor methods' => sub {
  isa_ok $subject->Red => $subject;
  isa_ok $subject->Yellow => $subject;
  isa_ok $subject->Green => $subject;

  ok $subject->Red->identical($subject->Red);
  ok $subject->Yellow->identical($subject->Yellow);
  ok $subject->Green->identical($subject->Green);
};

package Color {
  use Llama::Union {
    Red   => { -unit => 0 },
    Green => { -unit => 1 },
    Blue  => { -unit => 2 },
  };
}

done_testing;
