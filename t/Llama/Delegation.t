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
  sub five { 5 }
  sub six { 6 }
}

package First {
  use Llama::Delegation;

  delegate two => 'second';
  delegate [qw(three four)] => 'second';
  delegate {five => 'cinco', six => 'seis'} => 'second';

  sub new { bless {}, $_[0] }
  sub one { 1 }
  sub second { shift->{second} //= Second->new }
}

my $first = First->new;
is $first->two => 2;

is $first->three => 3;
is $first->four => 4;

is $first->cinco => 5;
is $first->seis => 6;

done_testing;
