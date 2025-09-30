package Llama::StackFrame;

use utf8;
use strict;
use warnings;
use feature qw(:5.20 signatures);
no warnings 'experimental::signatures';

use overload '""' => sub{shift->Str}, 'bool' => sub{1};

sub current ($class) {
  return $class->at(1);
}

sub trace ($class) {
  my @trace = ();
  my $i = 0;
  my $frame = $class->at($i);
  until ($frame->is_empty) {
    push @trace, $frame;
    $i++;
    $frame = $class->at($i);
  }
  return wantarray ? @trace : \@trace;
}

sub at ($class, $position) {
  my @frame = caller($position);
  return $class->EMPTY unless @frame;

  return $class->new(\@frame);
}

sub EMPTY ($class) { state $EMPTY = $class->new([]) }

sub new ($class, $trace) {
  bless $trace, $class;
}

sub package    ($self) { $self->[0] }
sub filename   ($self) { $self->[1] }
sub line       ($self) { $self->[2] }
sub subroutine ($self) { $self->[3] }
sub has_args   ($self) { $self->[4] }
sub wantarray  ($self) { $self->[5] }
sub evaltext   ($self) { $self->[6] }
sub is_require ($self) { $self->[7] }
sub hints      ($self) { $self->[8] }
sub bitmask    ($self) { $self->[9] }
sub hint_hash  ($self) { $self->[10] }

{
  # aliases
  no strict 'refs';
  no warnings 'once';
    
  *sub  = \&subroutine;
  *file = \&filename;
  *pkg  = \&package;
}

sub is_empty ($self) { !@$self }

sub Str ($self) {
  my $file = $self->file;
  my $line = $self->line;
  my $pkg  = $self->pkg;
  my $sub  = $self->sub;

  return "$sub in $pkg at $file line $line";
}

1;
