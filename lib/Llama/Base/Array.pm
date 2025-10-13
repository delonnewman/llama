package Llama::Base::Array;
use Llama::Prelude qw(+Base :signatures);

use overload '@{}' => sub{shift->ArrayRef};

sub allocate ($class, @args) {
  bless [], $class;
}

sub toArrayRef ($self) { $self }

1;
