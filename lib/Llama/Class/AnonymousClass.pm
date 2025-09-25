package Llama::Class::AnonymousClass;
use Llama::Base qw(+Class :signatures);

sub new($class) {
  my $name = '';
  my $object = bless \$name, $class;

  $name .= "$class=OBJECT(" . sprintf("0x%06X", $object->__addr__) . ')';
  $object->mro($Llama::Class::DEFAULT_MRO);
  Llama::Class::InstanceCache->set($name, $object);

  $object;
}

1;
