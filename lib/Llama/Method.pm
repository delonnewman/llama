package Llama::Method;
use Llama::Prelude qw(+Base::Code :signatures);

sub new ($class, $object, $method, @args) {
  my $self = $class->next::method(sub { $object->$method(@args, @_) });
  $self->set_name(ref($object) . "::$method");
}

1;
