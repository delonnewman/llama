package Llama::Class::Product;
use Llama::Prelude qw(+Class :signatures);

sub add_member ($self, $member, $name = undef) {
  $name //= $member->name;
  $self->add_attribute($name, $member);
  return $self;
}

1;
