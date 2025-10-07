package Llama::Sum::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Class::Sum';
require_ok $described_class;

subtest 'kind' => sub {
  my $class = $described_class->new;
  is Llama::Class->named($class->name)->kind => $described_class;
};

require Llama::Base::Symbol;
package Sum::Light::Red { use Llama::Base qw(+Base::Symbol) }
package Sum::Light::Yellow { use Llama::Base qw(+Base::Symbol) }
package Sum::Light::Green { use Llama::Base qw(+Base::Symbol) }

subtest 'class hierarchy' => sub {
  my $class = $described_class->new('Sum::Light')
    ->add_member(Sum::Light::Red->class)
    ->add_member(Sum::Light::Yellow->class)
    ->add_member(Sum::Light::Green->class);

  isa_ok $_->name => $class->name for $class->members;
};

done_testing;
