package Llama::Class::Sum;
use Llama::Base qw(+Class :signatures);

no strict 'refs';

sub new ($class, @args) {
  my $self = $class->next::method(@args);

  %{$self->package->qualify('MEMBERS')} = ();
  $self->kind($class);

  return $self;
}

sub add_member ($self, $member, $name = $member->name) {
  $member->prepend_superclasses($self->name);
  ${$self->package->qualify('MEMBERS')}{$name} = $member;

  return $self;
}

sub members ($class, @keys) {
  my %members = %{$class . '::MEMBERS'};
  my @members = @keys ? map { $members{$_} } @keys : values %members;

  return wantarray ? @members : int @members;
}

sub all ($class, @keys) {
  return wantarray ? $class->members(@keys) : [$class->members(@keys)];
}

sub names ($class) {
  my @names = keys %{$class . '::MEMBERS'};
  return wantarray ? @names : \@names;
}

sub of ($class, $type) {
  my %members = %{$class . '::MEMBERS'};
  return $members{$type} // do {
    my $valid = join ', ' => sort(keys %members);
    Carp::croak "invalid $class type ($type) valid values are ($valid)";
  };
}

sub new_of ($class, $type, @args) { $class->of($type)->new(@args) }

1;
