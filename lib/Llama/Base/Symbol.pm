package Llama::Base::Symbol;
use Llama::Prelude qw(+Base :signatures);

my %SYMBOLS = ();

sub new ($class) {
  return $SYMBOLS{$class} //= bless \$class, $class;
}

1;
