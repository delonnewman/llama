use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::Class::EigenClass {
  use Llama::Object '+Class::AnonymousClass';

  sub new($class, $object) {
    my $new_class = $class->next::method;
    my $orig_class = $object->CLASS;

    # make original class a super class
    $new_class->append_superclasses($object->CLASS_NAME);

    # bless object into new class
    $object->BLESS($new_class->name);

    # copy attributes from original class
    $object->ADD_ATTRIBUTE($_) for $orig_class->attributes;

    $new_class;
  }
}

1;
