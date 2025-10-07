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
$subject = 'Color';

subtest 'unit members' => sub {
  ok $_->isa('Llama::Class::Unit') for $subject->class->members;
};

package Result {
  use Llama::Union {
    Ok    => { -record => { value => 'Any' } },
    Error => { -record => { message => 'Str' } },
  };
}
$subject = 'Result';

subtest 'record members' => sub {
  isa_ok $_ => 'Llama::Class::Product', "$_ is a Llama::Class::Product" for $subject->class->members;
  ok $_->is_subclass('Llama::Base::Hash'), "$_ subclasses Llama::Base::Hash" for $subject->class->members;

  my $ok = Result->Ok(value => 1);
  is $ok->value => 1;

  my $error = Result->Error(message => 'Hey!');
  is $error->message => 'Hey!';
};

done_testing;
