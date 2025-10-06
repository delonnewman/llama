package Llama::Class::Sum;
use Llama::Base qw(+Class :signatures);

no strict 'refs';

sub new ($class, $name) {
  my $self = $class->next::method($name);
  %{$self->package->qualify('MEMBERS')} = ();

  return $self;
}

sub add_member ($self, $member) {
  $member->append_superclasses($self->name);
  ${$self->package->qualify('MEMBERS')}{$member->name} = $member;

  return $self;
}

1;
