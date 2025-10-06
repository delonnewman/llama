package Llama::Class::Product;
use Llama::Base qw(+Class :signatures)

sub add_member ($self, $member, $name = $member->name) {
  $self->add_attribute($name, $member);
  return $self;
}

1;
