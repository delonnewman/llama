package Llama::Base::Array;
use Llama::Prelude qw(+Base :signatures);

sub allocate ($class, @args) {
  bless \@args, $class;
}

1;
