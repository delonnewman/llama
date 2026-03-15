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
  use Data::Printer;
  our @ISA = qw(Llama::Parser::Result);

  sub value ($self) { $self->{value} }
  sub rest ($self) { $self->{rest} }

  sub is_ok { 1 }

  sub is_terminal ($self) {
    my $rest = $self->rest;
    return !!1 if !defined $rest || $rest eq '';

    my $ref = ref $rest;
    return !!1 if $ref eq 'ARRAY' && !@$rest;
    return !!1 if $ref eq 'HASH'  && !%$rest;

    return !!'';
  }

  sub pair ($self, $other) {
    Llama::Parser::Result::Pair->empty->pair($self)->pair($other);
  }
}

package Llama::Parser::Result::Pair {
  use Data::Printer;
  our @ISA = qw(Llama::Parser::Result::Ok);

  sub new ($self, $first, $next) {
    my $class = ref($self) || $self;
    bless [$first, $next] => $class;
  }

  sub first ($self) { $self->[0] }
  sub next ($self) { $self->[1] }

  sub value ($self) { $self->first->value }
  sub rest ($self) { $self->first->rest }

  sub empty ($self) {
    my $class = ref($self) || $self;
    state $empty = $class->new(undef, undef);
  }

  sub is_empty ($self) {
    !defined($self->[0]) && !defined($self->[1]);
  }

  sub pair ($self, $result) {
    if ($self->is_empty) {
      return $self->new($result, undef);
    }
    return $self->new($result, $self);
  }

  sub toArrayRef ($self) {
    my @array;
    my $current = $self;
    while ($current) {
      unshift @array => $current->first->value;
      $current = $current->next;
    }
    \@array;
  }

  sub toStr ($self) {
    if (!$self->next) {
      'Pair(' . np($self->first->value) . ', Empty)';
    } else {
      'Pair(' . np($self->first->value) . ', ' . $self->next->toStr . ')';
    }
  }
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
