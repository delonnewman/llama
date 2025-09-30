package Llama::Union;
use Llama::Base qw(:base :signatures);

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

  Llama::Union::Member->new($class, $key)->build;

  return $class;
};

1;
