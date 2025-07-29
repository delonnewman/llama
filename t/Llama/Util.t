package Llama::Util::Test;
use Test::More;
use lib qw(../../lib);

use Llama::Util qw(chomped);

is chomped "hiya\n", "hiya";

done_testing;
