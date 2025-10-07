package Llama::Class::Unit;
use Llama::Base qw(+Class :signatures);

use Carp ();
no strict 'refs';

my %UNITS = ();

sub new ($class, @args) {
  my ($name, $value) = @args > 1 ? @args[0..1] : (undef, $args[0]);
  Carp::croak "a value is required" unless defined $value;

  my $self = $class->next::method($name);
  $self->append_superclasses('Llama::Base');
  $self->kind($class);
  $self->unit($value);

  $name //= $self->name;
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
