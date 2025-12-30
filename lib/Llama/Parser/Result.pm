package Llama::Parser::Result;
use Llama::Prelude qw(:signatures);

sub Ok ($, @args) { Llama::Parser::Result::Ok->new(@args) }
sub Void ($, @args) { Llama::Parser::Result::Void->new(@args) }
sub Error ($, @args) { Llama::Parser::Result::Error->new(@args) }
sub CompositeError ($, @args) { Llama::Parser::Result::CompositeError->new(@args) }

sub new ($class, %attributes) {
  bless \%attributes => $class;
}

sub is_error { 0 }
sub is_ok { 0 }
sub is_void { 0 }

package Llama::Parser::Result::Ok {
  our @ISA = qw(Llama::Parser::Result);

  sub value ($self) { $self->{value} }
  sub rest ($self) { $self->{rest} }

  sub is_terminal ($self) { !$self->rest }
  sub is_ok { 1 }
}

package Llama::Parser::Result::Void {
  our @ISA = qw(Llama::Parser::Result::Ok);
  sub is_void ($self) { 1 }
}

package Llama::Parser::Result::Error {
  our @ISA = qw(Llama::Parser::Result);

  sub message ($self) { $self->{message} }

  sub is_terminal { 1 }
  sub is_error { 1 }
}

package Llama::Parser::Result::CompositeError {
  our @ISA = qw(Llama::Parser::Result::Error);

  sub messages ($self) { $self->{messages} }
  sub message ($self) {
    $self->{message} //= join "; " => $self->messages->@*;
  }
}

1;
