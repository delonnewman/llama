package Llama::Union;
use Llama::Base qw(+Base::Symbol :signatures);

use Data::Printer;
use Llama::Class;
use Llama::Class::Sum;
use Llama::Base::Symbol;

no warnings 'experimental::signatures';

sub import($class, @union) {
  my $name  = caller;
  my $union = Llama::Class::Sum->named($name);
  $union->append_superclasses(__PACKAGE__);

  if (@union) {
    for my $subtype (@union) {
      my $member_name = $name . '::' . $subtype;
      my $class = Llama::Class->named($member_name);

      $union->add_member($class, $subtype);
      $union->add_method($subtype, sub ($class) { "$class\::$subtype"->new });
    }
  }
}

sub members ($self, @keys) {
  return $self->class->members(@keys) unless wantarray;
  return map { $_->new_instance } $self->class->members(@keys);
}

sub all ($self, @keys) {
  my @members = map { $_->new_instance } $self->class->all(@keys);
  return wantarray ? @members : \@members;
}

sub of ($self, $key) {
  return $self->class->new_of($key);
}

1;
