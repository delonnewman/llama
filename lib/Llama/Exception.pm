package Llama::Exception;

use utf8;
use strict;
use warnings;
use feature qw(:5.20);
use experimental qw(signatures);

use overload '""' => sub{shift->toStr}, 'bool' => sub{1};

use Llama::StackFrame;

sub new ($class, $message) {
  my $name  = ref($class) || $class;
  my $trace = Llama::StackFrame->trace;
  bless { name => $name, message => $message, stacktrace => $trace }, $class;
}

sub name       ($self) { $self->{name} }
sub message    ($self) { $self->{message} }
sub stacktrace ($self) { $self->{stacktrace} }

{
  # aliases
  no strict 'refs';
  *__name__ = \&name;  
}

sub toStr ($self) {
  my $name    = $self->name;
  my $message = $self->message;
  my $trace   = join "\n" => map { "  $_" } $self->stacktrace->@*;

  return "$name: $message\n$trace\n";
}

package Llama::TypeError {
  our @ISA = qw(Llama::Exception);
}

package Llama::ArgumentError {
  our @ISA = qw(Llama::Exception);
}

package Llama::NotImplementedError {
  our @ISA = qw(Llama::Exception);
}

package Llama::AttributeError {
  our @ISA = qw(Llama::Exception);
}

1;
