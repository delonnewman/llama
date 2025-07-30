package Llama::Core::Test;
use Test::More;
use lib qw(../../lib);

use Llama::Core qw(chomped);

is chomped "hiya\n", "hiya";
is chomped "hiya", "hiya";

done_testing;
