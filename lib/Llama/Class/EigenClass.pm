use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::Class::EigenClass {
  use Llama::Object '+Class::AnonymousClass';
  use Data::Printer;

  sub new($class, $object) {
    my $new_class = $class->next::method;
    my $orig_class = $object->CLASS;

    # make original class a super class
    $new_class->append_superclasses($object->CLASS_NAME);

    # bless object into new class
    $object->BLESS($new_class->name);

    # copy attributes from original class
    for my $name ($orig_class->attributes) {
      my $attribute = $orig_class->attribute($name);
      $new_class->add_attribute($attribute);
    }

    $new_class;
  }
}

1;
