package Llama::Parser::Result;
use Llama::Prelude qw(:signatures);

sub Ok ($, @args) { Llama::Parser::Result::Ok->new(@args) }
sub Error ($, @args) { Llama::Parser::Result::Error->new(@args) }

sub new ($class, %attributes) {
  bless \%attributes => $class;
}

sub is_error { 0 }
sub is_ok { 0 }

package Llama::Parser::Result::Ok {
  our @ISA = qw(Llama::Parser::Result);

  sub value ($self) { $self->{value} }
  sub rest ($self) { $self->{rest} }

  sub is_terminal ($self) { !$self->rest }
  sub is_ok { 1 }
}

package Llama::Parser::Result::Error {
  our @ISA = qw(Llama::Parser::Result);

  sub message ($self) { $self->{message} }

  sub is_terminal { 1 }
  sub is_error { 1 }
}

1;
