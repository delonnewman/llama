use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::EigenClass {
  use Llama::Object '+AnonymousClass';

  sub new($class, $object) {
    my $new_class = $class->next::method;
    $new_class->add_superclass($object->CLASS_NAME);

    # re-bless $self into new class
    bless $object, $new_class->name;

    $new_class;
  }
}

1;
