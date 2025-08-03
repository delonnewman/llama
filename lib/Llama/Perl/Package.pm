package Llama::Perl::Package;
use strict;
use warnings;
use utf8;
use feature 'signatures';

no strict 'refs';

use Carp ();
use Module::Load ();

use Llama::Util ();

use constant META_PKG => '__META_PKG__';

# TODO: Move file oriented methods to subclass Llama::Perl::Module

sub named($class, $name) {
  my $sym = $name . '::' . META_PKG;
  my $pkg = ${$sym};
  unless ($pkg) {
    $pkg = $class->new($name);
    ${$sym} = $pkg;
  }
  $pkg;
}

sub new ($class, $name) {
  $name // Carp::croak("a name is required");

  bless \$name, $class;
}

sub maybe_load ($self) {
  $self->load unless $self->is_loaded;
  $self;
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

sub VERSION ($self) {
  $self->read_symbol('VERSION', 'SCALAR');
}

sub nested ($self, $name) {
  my $class = ref($self);
  $class->new($self->qualify($name));
}

sub alias ($self, %aliases) {
  for my $original (keys %aliases) {
    my $alias = $aliases{$original};
    Carp::croak "aliases should be fully qualified, " .
      "got '$alias' instead" unless $alias =~ /::/;

    *{$alias} = *{$self->qualify($original)};
  }

  $self;
}

sub read_symbol ($self, $name, $type) {
  *{$self->qualify($name)}{$type};
}

sub add_symbol ($self, $name, $value, $type = undef) {
  my ($is_valid, $value_type) = Llama::Util::valid_value_type($value, $type);
  Carp::confess "symbol value is not the correct type: " .
    "got $value_type, expected $type" if $type && !$is_valid;

  *{$self->qualify($name)} = $value;
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
  my %table = %{$self->symbol_table_name};
  wantarray ? %table : {%table};
}

sub symbol_table_name { shift->name . '::' }

sub ISA ($self, @parents) {
  if (@parents) {
    @{$self->name . '::ISA'} = @parents;
    return $self;
  }

  my @copy = @{$self->name . '::ISA'};
  wantarray ? @copy : [@copy];
}

1;

