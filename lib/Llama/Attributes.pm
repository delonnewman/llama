package Llama::Attributes;
use Llama::Base qw(:signatures);

use Llama::Package;

# macro functions for declaratively building attributes

sub import ($class) {
  my $caller = caller;
  my $pkg    = Llama::Package->named($caller);

  $pkg->add_sub('has', sub ($name, @args) {
    say "adding attribute $name, @args";
    $caller->class->add_attribute($name, @args);
  });
}

1;
