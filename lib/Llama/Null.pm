package Llama::Null;
use Llama::Base qw(:base :abstract);

*if_null   = \&Llama::Base::tap;
*if_falsy  = \&Llama::Base::tap;
*if_truthy = \&Llama::Base::itself;

sub Bool { 0 }

sub SCALAR {
  state $SCALAR = Llama::Null::Scalar->new(undef);
}

sub HASH {
  Llama::Null::Hash->new;
}

sub ARRAY {
  Llama::Null::Array->new;
}

sub CODE {
  state $CODE = Llama::Null::Code->new(sub{});
}

package Llama::Null::Scalar {
  use Llama::Base qw(+Base::Scalar +Null);
}

package Llama::Null::Hash {
  use Llama::Base qw(+Base::Hash +Null);
}

package Llama::Null::Array {
  use Llama::Base qw(+Base::Array +Null);
}

package Llama::Null::Code {
  use Llama::Base qw(+Base::Code +Null);
}

1;
