package Llama::Class::Sum;
use Llama::Base qw(+Class :signatures);

sub new ($class, $name, @members) {
  my $sum = $class->next::method($name);

  for my $member (@members) {
    $member->append_superclasses($name);
  }

  return $sum;
}

1;
