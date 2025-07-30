package Llama::Core::Test;
use Test::More;
use lib qw(../../lib);

use Llama::Core qw(chomped);

is chomped "hiya\n", "hiya";

done_testing;
