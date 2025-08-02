package Llama::Null;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object qw(:base :abstract);

sub if_null ($self, $block) {
  $block->();
  $self;
}

{
  no strict 'refs';
  no warnings 'once';
  *if_falsy = \&if_null;
}

sub if_truthy ($self, $_block) { $self }

sub Bool { 0 }

sub SCALAR {
  Llama::Null::Scalar->allocate('');
}

sub HASH {
  Llama::Null::Hash->allocate();
}

sub ARRAY {
  Llama::Null::Array->allocate();
}

sub CODE {
  Llama::Null::Code->allocate(sub{@_});
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
