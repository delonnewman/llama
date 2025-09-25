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
  *if_truthy = \&Llama::Base::itself;
  *if_falsy = \&Llama::Base::tap;
}

package Llama::Boolean::TRUE {
  sub Str { 'true' }
  *if_truthy = \&Llama::Base::tap;
  *if_falsy = \&Llama::Base::itself;
}

1;
