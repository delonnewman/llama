package Llama::Package;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();
use Module::Load ();

use Llama::Util qw(valid_value_type);

sub new ($class, $name) {
  $name // Carp::croak("a name is required");

  bless \$name, $class;
}

sub name ($self) {
  wantarray ? split('::', $$self) : $$self;
}

sub path_name ($self) {
  local $_ = $self->name;
  s/::/\//;
  "$_.pm";
}

# TODO: add a method that can determine if the package is loaded
# sub is_loaded {

# }

sub load {
  my $self = shift;
  $self = $self->new(shift) if $self eq __PACKAGE__;

  Module::Load::load($self->name);

  $self;
}

sub nested_package ($self, $name) {
  __PACKAGE__->new($self->qualify($name));
}

sub alias ($self, %aliases) {
  for my $original (keys %aliases) {
    my $alias = $aliases{$original};
    Carp::croak "aliases should be fully qualified, got: $alias" unless $alias =~ /::/;

    {
      no strict 'refs';
      *{$alias} = *{$self->qualify($original)};
    }
  }

  $self;
}

sub add_symbol ($self, $name, $value, $type = undef) {
  my ($is_valid, $value_type) = valid_value_type($value, $type);
  Carp::croak "symbol value is not the correct type: got $value_type, expected $type" if defined($is_valid) && !$is_valid;

  {
    no strict 'refs';
    *{$self->qualify($name)} = $value;
  }

  $self;
}

sub qualify ($self, @parts) {
  join('::', $self->name, @parts);
}

sub symbol_names ($self, $type = undef) {
  my %table = $self->symbol_table;
  my @names = keys %table;
  @names = grep { defined($table{$_}{$type}) } @names if $type;

  wantarray ? keys %table : [keys %table];
}

sub symbol_table ($self) {
  {
    no strict 'refs';
    my %table = %{$self->symbol_table_name};
    wantarray ? %table : {%table};
  }
}

sub symbol_table_name { shift->name . '::' }

1;

__END__

my $package = Llama::Package->new('Llama::Core');
$package->subroutine_names
