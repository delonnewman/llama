package Llama::Method;
use Llama::Prelude qw(+Base::Code :signatures);

sub new ($class, $object, $method, @args) {
  my $self = $class->next::method(sub { $object->$method(@args, @_) });
  my $pkg  = ref($object) || $object;
  $self->set_name("$pkg\::$method");
}

1;
