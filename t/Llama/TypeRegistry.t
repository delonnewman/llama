package Llama::TypeRegistry::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Attribute::TypeRegistry';
require_ok $described_class;

my $repository = $described_class->new;

my @examples = (
 {
    type => 'InstanceOf(Forest::Entity)',
    form => ['InstanceOf', 'Forest::Entity'],
 },
 {
    type => 'Any',
    form => ['Any'],
 },
);

for my $example (@examples) {
  is_deeply $repository->parse_tag($example->{type}) => $example->{form} => $example->{type};
}

done_testing;
