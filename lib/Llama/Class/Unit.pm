package Llama::Class::Unit;
use Llama::Base qw(+Class :signatures);

use Carp ();
no strict 'refs';

my %UNITS = ();

sub new ($class, @args) {
  my ($name, $value, $base) = @args > 1 ? @args[0..2] : (undef, $args[0], undef);
  Carp::croak "a value is required" unless defined $value;

  my $self = $class->next::method($name);
  $name //= $self->name;
  $base //= 'Llama::Base';

  $self->superclasses($base);
  $self->unit($value);

  $self->add_method('new', sub ($class) {
    $UNITS{$name} //= bless \$value, $class;
  });
}

sub unit ($self, @args) {
  if (@args) {
    ${$self->package->qualify('ATTRIBUTE_DATA')}{__unit__} = $args[0];
    return $self;
  }

  return ${$self->package->qualify('ATTRIBUTE_DATA')}{__unit__};
}

1;
