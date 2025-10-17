package Llama::Class::Sum;
use Llama::Prelude qw(+Class :signatures);

no strict 'refs';

sub new ($class, @args) {
  my $self = $class->next::method(@args);

  %{$self->package->qualify('MEMBERS')} = ();

  return $self;
}

sub add_member ($self, $member, $name = $member->name) {
  $member->prepend_superclasses($self->name);
  ${$self->package->qualify('MEMBERS')}{$name} = $member;

  return $self;
}

sub members ($self, @keys) {
  my %members = %{$self->name . '::MEMBERS'};
  my @members = @keys ? map { $members{$_} } @keys : values %members;

  return wantarray ? @members : int @members;
}

sub all ($class, @keys) {
  return wantarray ? $class->members(@keys) : [$class->members(@keys)];
}

sub names ($self) {
  my @names = keys %{$self->name . '::MEMBERS'};
  return wantarray ? @names : \@names;
}

sub of ($self, $type) {
  my %members = %{$self->name . '::MEMBERS'};
  return $members{$type} // do {
    my $valid = join ', ' => sort(keys %members);
    Carp::croak "invalid $self type ($type) valid values are ($valid)";
  };
}

sub new_of ($class, $type, @args) { $class->of($type)->new(@args) }

1;
