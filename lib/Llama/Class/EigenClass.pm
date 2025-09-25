use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::Class::EigenClass {
  use Llama::Base '+Class::AnonymousClass';
  use Data::Printer;

  sub new($class, $how) {
    my $new_class  = $class->next::method;
    my $orig_class = $how->class;

    # make original class a super class
    $new_class->append_superclasses($orig_class->name);

    # bless object into new class
    $how->BLESS($new_class->name);

    # copy attributes from original class
    for my $name ($orig_class->attributes) {
      my $attribute = $orig_class->attribute($name);
      $new_class->add_attribute($attribute);
    }

    $new_class;
  }
}

1;
