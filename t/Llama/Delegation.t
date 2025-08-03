package Llama::Delegation::Test;
use strict;
use warnings;
use utf8;

use Test::More;
use lib qw(../../lib);

package Second {
  sub new { bless {}, $_[0] }
  sub two { 2 }
  sub three { 3 }
  sub four { 4 }
}

package First {
  use Llama::Delegation;

  delegate two => 'second';
  delegate [qw(three four)] => 'second';

  sub new { bless {}, $_[0] }
  sub one { 1 }
  sub second { shift->{second} //= Second->new }
}

my $first = First->new;
is $first->two => 2;

is $first->three => 3;
is $first->four => 4;

done_testing;
