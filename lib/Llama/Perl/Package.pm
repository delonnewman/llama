package Llama::Perl::Package;
use strict;
use warnings;
use utf8;
use feature 'signatures';

no strict 'refs';

use Carp ();
use Module::Load ();
use Scalar::Util ();

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
  $self = $self->named(shift) if $self eq __PACKAGE__;

  Module::Load::load($self->name);

  $self;
}

sub try ($self, $method_name, @args) {
  if (my $method = $self->can($method_name)) {
    return $self->$method(@args);
  }
  return undef;
}

sub is_loaded ($self) { !!$self->full_path }
sub full_path ($self) { $INC{$self->path_name}; }

sub path_name ($self) {
  local $_ = $self->name;
  s/::/\//;
  "$_.pm";
}

sub name ($self) { wantarray ? split('::', $$self) : $$self }

sub VERSION ($self) { $self->name->VERSION }

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

sub get_sub ($self, $name) { $self->read_symbol($name, 'CODE') }

sub read_symbol ($self, $name, $type) {
  *{$self->qualify($name)}{$type};
}

sub add_sub ($self, $name, $code) { $self->add_symbol($name, $code, 'CODE') }

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
  my %table = $self->symbol_table->%*;
  Carp::carp "symbol table is empty this could mean that " .
    "the package isn't loaded, try calling the 'load' method" unless %table;

  my @names = keys %table;
  return wantarray ? @names : \@names unless $type;

  @names = grep {
    ref(\$table{$_}) eq 'GLOB' && defined(*{$table{$_}}{$type})
  } @names;

  wantarray ? @names : \@names;
}

sub symbol_table ($self) {
  wantarray ? %{$self->symbol_table_name} : \%{$self->symbol_table_name};
}

sub symbol_table_name { shift->name . '::' }

sub ISA ($self, @parents) {
  if (@parents) {
    @{$self->qualify('ISA')} = @parents;
    return $self;
  }

  wantarray ? @{$self->qualify('ISA')} : \@{$self->qualify('ISA')};
}

1;

