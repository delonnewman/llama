package Llama::Collection::Map;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use overload 'bool' => sub{0};

use Llama::Object qw(+HashObject +Associative);

1;
