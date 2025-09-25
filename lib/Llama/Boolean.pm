package Llama::Boolean;
use Llama::Base qw(+ScalarObject :abstract :signatures);

sub FALSE {
  state $false = do {
    my $value = 0;
    bless \$value, 'Llama::Boolean::False';
  };
}

sub TRUE {
  state $true = do {
    my $value = 1;
    bless \$value, 'Llama::Boolean::True';
  };
}

sub Num ($self) { $self->value }
*Bool = \&Num;

package Llama::Boolean::False {
  use Llama::Base qw(+Boolean :abstract);

  sub Str { 'false' }
  sub if_truthy($self, $_block) { $self }
  sub if_falsy($self, $block) {
    $block->();
    $self
  }
}

package Llama::Boolean::True {
  use Llama::Base qw(+Boolean :abstract);

  sub Str { 'true' }
  sub if_falsy($self, $_block) { $self }
  sub if_truthy($self, $block) {
    $block->();
    $self
  }
}

1;
