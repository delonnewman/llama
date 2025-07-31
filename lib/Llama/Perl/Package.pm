package Llama::Perl::Package;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();
use Module::Load ();

use Llama::Util ();

# TODO: Move file oriented methods to subclass Llama::Perl::Module

sub new ($class, $name) {
  $name // Carp::croak("a name is required");

  bless \$name, $class;
}

sub load {
  my $self = shift;
  $self = $self->new(shift) if $self eq __PACKAGE__;

  Module::Load::load($self->name);

  $self;
}

sub is_loaded ($self) { !!$self->full_path }
sub full_path ($self) { $INC{$self->path_name}; }

sub path_name ($self) {
  local $_ = $self->name;
  s/::/\//;
  "$_.pm";
}

sub name ($self) { wantarray ? split('::', $$self) : $$self }

sub nested ($self, $name) {
  my $class = ref($self);
  $class->new($self->qualify($name));
}

sub alias ($self, %aliases) {
  for my $original (keys %aliases) {
    my $alias = $aliases{$original};
    Carp::croak "aliases should be fully qualified, " .
      "got '$alias' instead" unless $alias =~ /::/;

    {
      no strict 'refs';
      *{$alias} = *{$self->qualify($original)};
    }
  }

  $self;
}

sub add_symbol ($self, $name, $value, $type = undef) {
  my ($is_valid, $value_type) = Llama::Util::valid_value_type($value, $type);
  Carp::confess "symbol value is not the correct type: " .
    "got $value_type, expected $type" if $type && !$is_valid;

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
  Carp::carp "symbol table is empty this could mean that " .
    "the package isn't loaded, try calling the 'load' method" unless %table;

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

