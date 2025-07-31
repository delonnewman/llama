package Llama::Core::Test;
use Test::More;
use lib qw(../../lib);

use Llama::IO qw(slurp spit);

mkdir 't/data';

# scalar context
my $c1 = spit('./t/data/test.txt', 'this is a test');
is $c1 => 'this is a test';
is slurp('./t/data/test.txt') => 'this is a test';

# array context
spit './t/data/test-array-context.txt', "this\nis\na\nlist";
my @lines = slurp('./t/data/test-array-context.txt');
is_deeply \@lines, ["this\n", "is\n", "a\n", "list"];
is slurp('./t/data/test-array-context.txt') => "this\nis\na\nlist";

done_testing;
