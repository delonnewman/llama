package Llama::Union::Test;
use Llama::Test::TestSuite;
use Feature::Compat::Try;
no warnings 'experimental::signatures';

my $described_class = 'Llama::Union';
require_ok $described_class;

# my $type = $described_class->build(name => 'PerlType', members => [qw(CODE HASH ARRAY SCALAR)]);
# my $scalar_subtype = $described_class->build(name => 'PerlType::SCALAR', members => ['REF'], supertype => 'PerlType');
# my $ref_subtype = $described_class->build(name => 'PerlType::SCALAR::REF', members => [qw(SCALAR CODE HASH ARRAY Blessed)], supertype => 'PerlType::SCALAR');

# subtest 'class hierarchy' => sub {
#   isa_ok $described_class, '';
# };

done_testing;
