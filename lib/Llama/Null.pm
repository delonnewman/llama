package Llama::Null;
use Llama::Prelude qw(+Base :abstract);

*if_null   = \&Llama::Base::tap;
*if_falsy  = \&Llama::Base::tap;
*if_truthy = \&Llama::Base::itself;
*then      = \&Llama::Base::itself;

sub Bool { 0 }

sub SCALAR {
  state $SCALAR = Llama::Null::Scalar->new('');
}

sub HASH {
  Llama::Null::Hash->new;
}

sub ARRAY {
  Llama::Null::Array->new;
}

sub CODE {
  state $CODE = Llama::Null::Code->new(sub{@_});
}

package Llama::Null::Scalar {
  use Llama::Prelude qw(+Base::Scalar +Null);
}

package Llama::Null::Hash {
  use Llama::Prelude qw(+Base::Hash +Null);
}

package Llama::Null::Array {
  use Llama::Prelude qw(+Base::Array +Null);
}

package Llama::Null::Code {
  use Llama::Prelude qw(+Base::Code +Null);
}

1;
