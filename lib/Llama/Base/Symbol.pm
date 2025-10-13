package Llama::Base::Symbol;
use Llama::Prelude qw(+Base :signatures);

no strict 'refs';

my %SYMBOLS = ();

sub new ($class) {
  return $SYMBOLS{$class} //= bless \$class, $class;
}

*name = \&Llama::Base::__name__;
*toStr = \&Llama::Base::__name__;

1;
