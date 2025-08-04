use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::EigenClass {
  use Llama::Object '+AnonymousClass';

  sub new($class, $object) {
    my $new_class = $class->next::method;

    $new_class->append_superclass($object->CLASS_NAME);
    $object->BLESS($new_class->name);

    $new_class;
  }
}

1;
