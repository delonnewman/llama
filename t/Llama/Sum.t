package Llama::Sum::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Class::Sum';
require_ok $described_class;

subtest 'kind' => sub {
  my $class = $described_class->new;

  is Llama::Class->named($class->name)->kind => $described_class;
};

done_testing;
