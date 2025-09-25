package Llama::Boolean;
use Llama::Base qw(:signatures);
use Llama::Enum {
  FALSE => 0,
  TRUE  => 1,
};

sub Num ($self) { $self->value }
*Bool = \&Num;

package Llama::Boolean::FALSE {
  sub Str { 'false' }
  sub if_truthy($self, $_block) { $self }
  sub if_falsy($self, $block) {
    $block->();
    $self
  }
}

package Llama::Boolean::TRUE {
  sub Str { 'true' }
  sub if_falsy($self, $_block) { $self }
  sub if_truthy($self, $block) {
    $block->();
    $self
  }
}

1;
