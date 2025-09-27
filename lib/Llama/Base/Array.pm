package Llama::Base::Array;
use Llama::Base qw(:base :constructor :signatures);

use overload '@{}' => sub{shift->ArrayRef};

sub allocate ($class, @args) {
  bless [], $class;
}

sub ArrayRef ($self) { $self }

1;
