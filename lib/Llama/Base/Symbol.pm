package Llama::Base::Symbol;
use Llama::Base qw(+Base :signatures);

my %cache = ();

sub new ($class) {
  $cache{$class} //= bless \$class, $class;
}
    
1;
