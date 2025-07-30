package Llama::Core::Test;
use Test::More;
use lib qw(../../lib);

use Llama::IO qw(slurp spit);

my $c1 = spit('./test.txt', 'this is a test');
is $c1 => 'this is a test';
is slurp('./test.txt') => 'this is a test';

# array context
spit './test-array-context.txt', "this\nis\na\nlist";
my @lines = slurp('./test-array-context.txt');
is_deeply \@lines, ["this\n", "is\n", "a\n", "list"];
is slurp('./test-array-context.txt') => "this\nis\na\nlist";

done_testing;
