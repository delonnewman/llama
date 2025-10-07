package Llama::Attributes;
use Llama::Base qw(:signatures);

use Llama::Package;

# macro functions for declaratively building attributes

sub import ($class) {
  my $caller = caller;
  my $pkg    = Llama::Package->named($caller);

  my $order = 0;
  $pkg->add_sub('has', sub ($name, $options) {
    $caller->class->add_attribute($name, { order => $order++, %$options });
  });
}

1;
