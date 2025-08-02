package Llama::Boolean;
use strict;
use warnings;
use utf8;
use feature 'signatures';
use feature 'state';

sub FALSE {
  state $false = Llama::Boolean::False->allocate(0)
}

sub TRUE {
  state $true = Llama::Boolean::True->allocate(1)
}

package Llama::Boolean::False {
  use Llama::Object '+ScalarObject';

  sub Bool { 0 }
  sub Str { 'false' }
  sub if_truthy($self, $_block) { $self }
  sub if_falsy($self, $block) {
    $block->();
    $self
  }
}

package Llama::Boolean::True {
  use Llama::Object '+ScalarObject';

  sub Bool { 1 }
  sub Str { 'true' }
  sub if_falsy($self, $_block) { $self }
  sub if_truthy($self, $block) {
    $block->();
    $self
  }
}

1;
