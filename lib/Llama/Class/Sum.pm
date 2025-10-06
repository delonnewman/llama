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

sub members($class, @keys) {
  my %members = %{$class . '::MEMBERS'};
  my @members = @keys ? map { $members{$_} } @keys : values %members;

  return wantarray ? @members : int @members;
}

sub all($class, @keys) {
  return wantarray ? $class->members(@keys) : [$class->members(@keys)];
}

sub of($class, $type) {
  my %members = %{$class . '::MEMBERS'};
  return $members{$type} // do {
    my $valid = join ', ' => sort(keys %members);
    Carp::croak "invalid $class type ($type) valid values are ($valid)";
  };
}

1;
