package Llama::Union;
use Llama::Base qw(+Base :signatures);

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
      p $member_name;
      my $class = Llama::Class->named($member_name);
      $class->append_superclasses('Llama::Base::Symbol');
      $union->add_member($class);
      $union->add_method($subtype, sub :prototype() { $class->name->new });
    }
  }
}

sub class ($self) {
  return Llama::Class::Sum->named($self->__name__);
}

1;
