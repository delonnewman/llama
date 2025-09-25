package Llama::Null;
use Llama::Base qw(:base :abstract);

sub if_null ($self, $block) {
  $block->();
  $self;
}

*if_falsy = \&if_null;
sub if_truthy ($self, $_block) { $self }

sub Bool { 0 }

sub SCALAR {
  Llama::Null::Scalar->new;
}

sub HASH {
  Llama::Null::Hash->new;
}

sub ARRAY {
  Llama::Null::Array->new;
}

sub CODE {
  Llama::Null::Code->new(sub{});
}

package Llama::Null::Scalar {
  use Llama::Base qw(+Base::Scalar +Null);
}

package Llama::Null::Hash {
  use Llama::Base qw(+Base::Hash +Null);
}

package Llama::Null::Array {
  use Llama::Object qw(+Base::Array +Null);
}

package Llama::Null::Code {
  use Llama::Object qw(+Base::Code +Null);
}

1;
