use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::Class::EigenClass {
  use Llama::Object '+Class::AnonymousClass';

  sub new($class, $object) {
    my $new_class = $class->next::method;

    # copy attributes from original class
    $new_class->add_attribute($_) for $object->CLASS->attributes;

    # make original class a super class
    $new_class->append_superclasses($object->CLASS_NAME);

    # bless object into new class
    $object->BLESS($new_class->name);

    $new_class;
  }
}

1;
