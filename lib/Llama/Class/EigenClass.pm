use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::Class::EigenClass {
  use Llama::Object '+Class::AnonymousClass';

  sub new($class, $object) {
    my $new_class = $class->next::method;

    $new_class->append_superclasses($object->CLASS_NAME);
    $object->BLESS($new_class->name);

    $new_class;
  }
}

1;
