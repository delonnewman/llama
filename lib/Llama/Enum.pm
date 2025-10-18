package Llama::Enum;
use Llama::Prelude qw(+Base::Scalar :signatures);

use Carp ();
use Scalar::Util qw(blessed);
use Data::Printer;

use Llama::Enum::Class;
use Llama::Enum::Member;

use overload (
  "cmp"  => sub($self, $other, $) { $self->key   cmp $self->parent->coerce($other)->key },
  "<=>"  => sub($self, $other, $) { $self->value <=> $self->parent->coerce($other)->value },
  "=="   => sub($self, $other, $) { $self->value == $self->parent->coerce($other)->value },
  "eq"   => sub($self, $other, $) { $self->key   eq $self->parent->coerce($other)->key },
  "!="   => sub($self, $other, $) { $self->value != $self->parent->coerce($other)->value },
  "ne"   => sub($self, $other, $) { $self->key   ne $self->parent->coerce($other)->key }
);

use constant KEYS_INDEX   => 'MEMBERS';
use constant VALUES_INDEX => 'MEMBERS_BY_VALUE';

# Base Class Methods (i.e. methods called on Llama::Enum)

# Called when the package is imported i.e. 'use Llama::Enum'.
# This is where all the magic happens!
#
# See https://perldoc.perl.org/functions/use
sub import($class, @args) {
  my ($enum_package) = caller;

  my %enum = ref $args[0] eq 'HASH' ? %{$args[0]} : map { uc $_ => uc $_ } @args;
  my $enum = Llama::Enum::Class->new($enum_package)->build($class);

  $enum->class->add($_, $enum{$_}) for keys %enum;
}

# Class Methods (i.e. methods called on the enum class,
# see Llama::Enum::Class::build to see the methods that are dynamically created).

sub coerce($class, $value) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  return $value             if blessed($value) && $value->isa(__PACKAGE__);
  return $class->of($value) if $class->is_value($value);
  return $class->keyed($value);
}

sub values_of ($class, @keys) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  my @values = map { $class->keyed($_)->value } @keys;
  wantarray ? @values : \@values;
}

sub is_key($class, $key) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  no strict 'refs';
  ${$class . '::' . KEYS_INDEX}{uc $key};
}

sub is_value($class, $value) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  no strict 'refs';
  ${$class . '::' . VALUES_INDEX}{$value};
}

sub members($class, @keys) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  no strict 'refs';
  my %members = %{$class . '::' . KEYS_INDEX};
  my @members = @keys ? map { $members{$_} } @keys : values %members;

  return wantarray ? @members : int @members;
}

sub all($class, @keys) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  return wantarray ? $class->members(@keys) : [$class->members(@keys)];
}

sub of($class, $value) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  no strict 'refs';
  my %members_by_value = %{$class . '::' . VALUES_INDEX};
  return $members_by_value{$value} // do {
    my $valid = join ', ' => sort(keys %members_by_value);
    Carp::croak "invalid $class value ($value) valid values are ($valid)";
  };
}

sub keyed($class, $key) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  $key = uc $key;
  no strict 'refs';
  my %members = %{$class . '::' . KEYS_INDEX};
  return $members{$key} // do {
    my $valid = join ', ' => keys %members;
    Carp::croak "invalid $class key (". np($key) .") valid keys are ($valid)";
  };
}

sub add($class, $key, $value = $key) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  Llama::Enum::Member->new($class, $key)->build($value);

  return $class;
};

sub add_key_mapping($class, $key, $object) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  no strict 'refs';
  ${$class . '::' . KEYS_INDEX}{$key} = $object;

  return $class;
}

sub add_value_mapping($class, $value, $object) {
  Carp::croak "invalid usage should only be called on subclasses" if $class eq __PACKAGE__;

  no strict 'refs';
  ${$class . '::' . VALUES_INDEX}{$value} = $object;

  return $class;
}

# Member Instance Methods (i.e. methods called on enum
# member instances e.g. MyEnum->KEY->name)

sub equals($self, $other) {
  return 0 unless blessed($other) && $other->isa($self->parent);

  return $self->key eq $other->key;
}

sub toStr ($self) {
  my $str = $self->parent . '(';
  $str .= $self->key eq $self->value ? $self->key : $self->key . ' => ' . $self->value;
  $str .= ")";
  return $str;
}

sub key($self) { [split('::', ref $self)]->[-1] }
sub value($self) { $$self }

1;

=encoding utf8

=head1 NAME

Llama::Enum - Object-Oriented Enum Types

=head1 SYNOPSIS

  # A lookup table
  package Llama::Color {
    use Llama::Enum {
      RED   => 0,
      GREEN => 1,
      BLUE  => 2,
    };

    sub Llama::Color::RED::hex { '#FF0000' }
    sub Llama::Color::GREEN::hex { '#00FF00' }
    sub Llama::Color::BLUE::hex { '#0000FF' }
  }

  # A state machine
  package Llama::EnrollmentStatus {
    use Llama::Enum qw(INIT PENDING SUCCESS FAILURE);

    sub is_terminal { 0 }
    sub can_transition($, $) { 0 }

    sub next($self, $ctx) {
      !$self->is_terminal && $self->can_transition($self, $ctx)
        ? $self->next_phase : FAILURE;
    }

    package Llama::EnrollmentStatus::INIT {
      sub can_transition($self, $ctx) { ... }
      sub next_phase { PENDING }
    }

    package Llama::EnrollmentStatus::PENDING {
      sub can_transition($self, $ctx) { ... }
      sub next_phase { SUCCESS }
    }

    package Llama::EnrollmentStatus::SUCCESS {
      sub is_terminal { 1 }
    }

    package Llama::EnrollmentStatus::FAILURE {
      sub is_terminal { 1 }
    }
  }

  package main;
  use Llama::Color -alias;
  use Llama::EnrollmentStatus -alias => 'Status';

  Color->RED->value # => 0
  Color->RED->key # => 'RED'
  Color->RED->hex # => '#FF0000'
  Color->RED->name # => 'Red'
  Status->INIT->value # 'INIT'
  Status->INIT->next # PENDING

  Color->all # => [RED, GREEN, BLUE]
  Color->of(2) # => BLUE
  Color->keyed('GrEen') # => GREEN

  # Validation
  Color->is_value(4) # => 0
  Color->is_value(0) # => 1
  Status->is_key('PendING') # => 1
  Status->is_value('Pending') # => 0
  Status->is_value('PENDING') # => 1

  # Coercion
  Color->coerce(0) # => RED
  Color->coerce(Color->RED) # => RED
  Color->coerce('reD') # => RED

  # Context
  Color->RED && "Hey" # => "Hey"
  Color->RED eq 'red' # => 1
  Color->RED eq Color->RED # => 1
  Color->RED == 0 # => 1
  Color->RED == Color->RED # => 1
  ''.Color->RED # => 'RED'
  Status->INIT eq 'init' # => 1
  Status->INIT == 3 # => 0, also provides a warning

=head1 DESCRIPTION

A simple mapping of a string key and a scalar value. When an array is provided
when importing the package the array elements each provide both the key and value.
Each key/value mapping is then used to define subclasses of the importing package
which enables the creation of polymorphic interfaces for the mapping.

=head1 METHODS

=head2 add

  Color->add('ALPHA', => 3) # => 'Llama::Color'
  Color->ALPHA # => Llama::Color(ALPHA => 3)

Adds a new member to the enum, if the value is an instance of the enum or a subclass it
will be added without being blessed. If the value is C<undef> the key will be copied as
the value.

=head2 all

  my @statuses = Status->all; # => (INIT PENDING SUCCESS FAILURE)
  my $statuses = Status->all; # => [INIT PENDING SUCCESS FAILURE]

Returns an array that includes all of the enum members. In scalar context it returns
an array reference. See L</"members">.

=head2 members

  my @members = Status->members; # => (INIT PENDING SUCCESS FAILURE)
  my $members = Status->members; # => 4

Returns an array that includes all of the enum members. In scalar context it returns
the number of enum members. See L</"all">.

=head2 coerce

  my $enum = Color->coerce('Red') # => RED
  $enum = Color->coerce(Color->RED) # => RED
  $enum = Color->coerce(0) # => RED
  Color->coerce("HEY") # die!

Attempt ot coerce a value into a valid enum member or die.

=head2 of

  my $enum = Color->of(2) # GREEN
  Color->of(5) # die!
  Status->of('INIT') # => INIT
  Status->of('inIT') # die!

Lookup an enum member by value or die. Note that this lookup is case-sensitive
if the values are strings. See L</"coerce">, L</"keyed">.

=head2 keyed

  my $enum = Color->keyed('BluE') # => BLUE
  Color->keyed('YELLOW') # die!
  Status->keyed('inIT') # => INIT

Lookup an enum member by key (case-insensitive).

=head2 is_value

  Color->is_key('grEEn') # => 1
  Color->is_key('YELLOW') #  => 0

Return truthy if the key is a valid, otherwise return falsy.

=head2 is_value

  Color->is_value(2) # => 1
  Color->is_value(10) #  => 0
  Status->is_value('INIT') # => 1
  Status->is_value('inIT') # => 0

Return truthy if the value is valid, otherwise return falsy. Note that this lookup
is case-sensitive if the values are strings. See L</"keyed">.

=head2 parent

  Color->RED->parent # 'Llama::Color'
  Status->INIT->parent # 'Llama::EnrollmentStatus'

Return the enum parent class.

=head2 key

  my $key = $enum->key;

Returns the key name (it will be converted to all caps internally). This method
should not be overridden by subclasses.

=head2 value

  my $value = $enum->value;

Returns instance value. This method should not be overridden by subclasses.

=head2 to_int

  my $int = $enum->to_int;

Attempts to coerce the value to an integer and returns that value. See L<int>.

=head2 to_string

  my $str = $enum->to_string;

The default implementation returns the key of the instance. This method is used
for string coercion and is designed to be overridden by subclasses as desired.

=head2 equals($other)

  $enum->equals($other);

Returns truthy if $other is an object that is an instance of the enum class and
it has the same key as $enum. Otherwise it returns falsy.

=head1 OPERATORS

=head2 bool

  my $bool = !!$enum;

Always truthy.

=head2 stingify

  my $str = "$enum";

Alias for L</"to_string">.

=head2 eq

  Color->RED eq 'Red' # => 1
  'inIT' eq Status->INIT # => 1
  Color->GREEN eq 'RED' # => 0

String comparison of keys.

=head2 ne

  Color->RED ne 'Red' # => 0
  'inIT' ne Status->INIT # => 0
  Color->GREEN ne 'RED' # => 1

Negation of L</"eq">.

=head2 ==

  Color->RED == 0 # => 1
  Color->RED == 2 # => 0

Numeric comparison of values. Will warn if values don't appear to be
numeric to Perl.

=head2 !=

  Color->RED != 0 # => 0
  Color->RED != 2 # => 1

Negation of L</"==">.

=head2 cmp

  sort(Color->RED, Color->GREEN, Color->BLUE) # => (BLUE, GREEN, RED)
  sort { $a cmp $b } (Color->RED, Color->GREEN, Color->BLUE) # => (BLUE, GREEN, RED)

String three way comparison of keys.

=head2 <=>

  sort(Color->RED, Color->GREEN, Color->BLUE) # => (BLUE, GREEN, RED)
  sort { $a <=> $b } (Color->BLUE, Color->RED, Color->GREEN) # => (RED, GREEN, BLUE)

Numeric three way comparison of values.

=cut

1;
