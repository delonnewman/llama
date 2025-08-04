use strict;
use warnings;
use utf8;
use feature 'signatures';

package Llama::AnonymousClass {
  use Llama::Object '+Class';

  sub new($class) {
    my $name = '';
    my $object = bless \$name, $class;

    $name .= "$class=OBJECT(" . sprintf("0x%06X", $object->ADDR) . ')';
    $object->mro($Llama::Class::DEFAULT_MRO);
    Llama::Class::cache_instance($name, $object);

    $object;
  }
}

1;
