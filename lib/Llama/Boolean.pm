package Llama::Boolean;
use strict;
use warnings;
use utf8;
use feature 'signatures';
use feature 'state';

my $false_pkg = 'Llama::Boolean::False';
my $true_pkg = 'Llama::Boolean::True';

sub false :prototype() {
  state $false = Llama::Boolean::False->allocate(0)
}

sub true :prototype() {
  state $true = Llama::Boolean::True->allocate(1)
}

package Llama::Boolean::False {
  use Llama::Object 'Llama::ScalarObject';

  use overload 'bool' => sub{0};

  sub object_id { state $object_id = Llama::Object->OBJECT_ID }
  sub to_string { 'false' }
  sub if_true($self, $_block) { $self }
  sub if_false($self, $block) { $block->(); $self }
}

package Llama::Boolean::True {
  use Llama::Object 'Llama::ScalarObject';

  use overload 'bool' => sub{1};

  sub object_id { state $object_id = Llama::Object->OBJECT_ID }
  sub to_string { 'true' }
  sub if_true($self, $block) { $block->(); $self }
  sub if_false($self, $_block) { $self }
}

1;
