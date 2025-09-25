package Llama::Boolean;
use Llama::Base qw(:signatures);
use Llama::Enum {
  FALSE => 0,
  TRUE  => 1,
};

sub Num ($self) { $self->value }
*Bool = \&Num;

sub coerce ($class, $value) {
  return $class->FALSE if !defined($value) || $value eq '';

  $class->next::method($value);
}

package Llama::Boolean::FALSE {
  sub Str { 'false' }
  sub if_truthy($self, $_block, @args) { $self }
  sub if_falsy($self, $block, @args) {
    $self->$block(@args);
    $self
  }
}

package Llama::Boolean::TRUE {
  sub Str { 'true' }
  sub if_falsy($self, $_block, @args) { $self }
  sub if_truthy($self, $block, @args) {
    $self->$block(@args);
    $self
  }
}

1;
