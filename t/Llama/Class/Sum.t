package Llama::Sum::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Class::Sum';
require_ok $described_class;

package Sum::Light::Red { use Llama::Base qw(+Base::Symbol) }
package Sum::Light::Yellow { use Llama::Base qw(+Base::Symbol) }
package Sum::Light::Green { use Llama::Base qw(+Base::Symbol) }

my $subject = $described_class->new('Sum::Light')
  ->add_member(Sum::Light::Red->class)
  ->add_member(Sum::Light::Yellow->class)
  ->add_member(Sum::Light::Green->class);

subtest 'kind' => sub {
  is Llama::Class->named($subject->name)->kind => $described_class;
};

subtest 'class hierarchy' => sub {
  isa_ok $_->name => $subject->name for $subject->members;
};

subtest 'subclassing' => sub {
  is_deeply scalar($subject->parents), [];

  $subject->parents('Llama::Base');
  ok $subject->is_subclass('Llama::Base');

  my $member = $subject->all->[0];
  $member->append_superclasses('Llama::Base::Hash');
  ok $member->is_subclass($_), "$member is subclass of $_" for ($subject->name, qw(Llama::Base Llama::Base::Hash));
};

done_testing;
