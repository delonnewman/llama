package Llama::Boolean;
use Llama::Prelude qw(:signatures);
# use Llama::Util qw(extract_flags);

use Llama::Enum {
  FALSE => 0,
  TRUE  => 1,
};

# sub import ($class, @args) {
#   my $caller = caller;
#   my %flags  = extract_flags \@args;

#   if ($flags{-symbols}) {
#     no strict 'refs';
#     *{$caller . '::true'}  = sub :prototype() { __PACKAGE__->TRUE };
#     *{$caller . '::false'} = sub :prototype() { __PACKAGE__->FALSE };
#   }
# }

sub Num  ($self) {   $self->value }
sub Bool ($self) { !!$self->value }

sub coerce ($class, $value) {
  return $class->FALSE if !defined($value) || $value eq '';

  $class->next::method($value);
}

package Llama::Boolean::FALSE {
  sub Str { 'false' }
  *if_truthy = \&Llama::Base::itself;
  *if_falsy = \&Llama::Base::tap;
}

package Llama::Boolean::TRUE {
  sub Str { 'true' }
  *if_truthy = \&Llama::Base::tap;
  *if_falsy = \&Llama::Base::itself;
}

1;
