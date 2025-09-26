package Llama::Pair::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Pair';
require_ok $described_class;

my $pair = $described_class->new(a => 1);
is $pair->key   => 'a';
is $pair->value =>  1;

my %pair = %$pair;
is $pair{a} => 1;

my @pair = @$pair;
is $pair[0] => 'a';
is $pair[1] =>  1;

done_testing;
