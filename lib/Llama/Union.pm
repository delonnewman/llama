package Llama::Union;
use Llama::Base qw(:base :signatures);

use Data::Printer;
use Llama::Union::Class;
use Llama::Union::Member;

no warnings 'experimental::signatures';

sub import($class, @union) {
  my $name  = caller;
  my $union = Llama::Union::Class->new($name)->build($class);

  $name->add($_) for @union;
}

sub add($class, $key) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  Llama::Union::Member->build($class, $key);

  return $class;
}

sub members($class, @keys) {
  no strict 'refs';
  my %members = %{$class . '::MEMBERS'};
  my @members = @keys ? map { $members{$_} } @keys : values %members;

  return wantarray ? @members : int @members;
}

sub all($class, @keys) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  return wantarray ? $class->members(@keys) : [$class->members(@keys)];
}

sub of($class, $type) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  no strict 'refs';
  my %members = %{$class . '::MEMBERS'};
  return $members{$type} // do {
    my $valid = join ', ' => sort(keys %members);
    Carp::croak "invalid $class type ($type) valid values are ($valid)";
  };
}

sub class ($self) {
  return Llama::Class->named(__PACKAGE__) if !Scalar::Util::blessed($self) && $self eq __PACKAGE__;
  return Llama::Union::Class->named($self->__name__);
}

1;
