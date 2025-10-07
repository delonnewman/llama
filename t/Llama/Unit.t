package Llama::Class::Unit::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Class::Unit';
require_ok $described_class;

my $class = $described_class->new(3.14159);
my $pi1 = $class->new_instance;
my $pi2 = $class->new_instance;

ok $$pi1 == $$pi2;
ok $pi1->identical($pi2);

done_testing;
