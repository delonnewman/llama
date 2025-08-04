package Llama::Null;
use strict;
use warnings;
use utf8;
use feature 'signatures';
no strict 'refs';

use Llama::Object qw(:base :abstract);

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
  use Llama::Object qw(+ScalarObject +Null);
}

package Llama::Null::Hash {
  use Llama::Object qw(+HashObject +Null);
}

package Llama::Null::Array {
  use Llama::Object qw(+ArrayObject +Null);
}

package Llama::Null::Code {
  use Llama::Object qw(+CodeObject +Null);
}

1;
