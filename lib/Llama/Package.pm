package Llama::Package;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();
use Module::Load ();

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

sub load {
  my $self = shift;
  $self = $self->new(shift) if $self eq __PACKAGE__;

  Module::Load::load($self->name);

  $self;
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

sub add_symbol ($self, $name, $body) {
  {
    no strict 'refs';
    *{$self->qualify($name)} = $body;
  }

  $self;
}

sub qualify ($self, @parts) {
  join('::', $self->name, @parts);
}

sub symbol_names ($self) {
  my %table = $self->symbol_table;
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
