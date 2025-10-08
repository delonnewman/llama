package Llama::Class::EigenClass;
use Llama::Prelude qw(+Class :signatures);

sub build($class, $mirror) {
  my $new_class  = $class->new;
  my $orig_class = $mirror->class;
  my $name = $orig_class->name;

  # make original class a super class
  $new_class->append_superclasses($orig_class->name);

  # bless object into new class
  $mirror->BLESS($new_class->name);

  return $new_class;
}

1;
