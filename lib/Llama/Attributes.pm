package Llama::Attributes;
use Llama::Prelude qw(:signatures);

use Llama::Package;

# macro functions for declaratively building attributes

my $EMPTY_HASH  = {};
my $EMPTY_ARRAY = [];

sub import ($class) {
  my $caller = caller;
  my $pkg    = Llama::Package->named($caller);

  my $order = 0;
  $pkg->add_sub('has', sub ($name, $options = $EMPTY_HASH) {
    $caller->class->add_attribute($name, { order => $order++, %$options });
  });

  $pkg->add_sub('has_many', sub ($name, $options = $EMPTY_HASH) {
    Llama::Package->named($options->{class})->maybe_load if $options->{class};
    $caller->class->add_attribute($name, { optional => 1, associated => 1, cardinality => 'many', default => sub {$EMPTY_ARRAY}, order => $order++, %$options });
  });
}

1;
