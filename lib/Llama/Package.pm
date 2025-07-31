package Llama::Package;
use strict;
use warnings;
use utf8;

use Carp ();
use Module::Load ();

sub new {
  my ($class, $name) = @_;
  Carp::croak("expected 2 arguments got ${int(@_)}") unless @_ == 2;

  $name // Carp::croak("a name is required");

  bless \$name, $class;
}

sub name {
  my $self = shift;

  wantarray ? split('::', $$self) : $$self;
}

sub load {
  my $self = shift;
  $self = $self->new(shift) if $self eq __PACKAGE__;

  Module::Load::load($self->name);

  $self;
}

sub alias {
  my $self = shift;

  my %aliases = @_;
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

sub define_subroutine {
  my $self = shift;
  my $name = shift;
  my $body = shift;

  {
    no strict 'refs';
    *{$self->qualify($name)} = $body;
  }

  $self;
}

sub qualify {
  my $self = shift;
  join('::', $self->name, @_);
}

sub subroutine_names {
  my $self = shift;

  my %table = $self->symbol_table;
  wantarray ? keys %table : [keys %table];
}

sub symbol_table {
  my $self = shift;
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
$package->symbol_table
