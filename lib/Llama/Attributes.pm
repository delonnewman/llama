package Llama::Attributes;
use Llama::Base qw(:signatures);

use Llama::Package;

# macro functions for declaratively building attributes

my $EMPTY_HASH = {};

sub import ($class) {
  my $caller = caller;
  my $pkg    = Llama::Package->named($caller);

  my $order = 0;
  $pkg->add_sub('has', sub ($name, $options = $EMPTY_HASH) {
    $caller->class->add_attribute($name, { order => $order++, %$options });
  });
}

1;
