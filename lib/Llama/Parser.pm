package Llama::Parser;
use Llama::Prelude qw(+Base :signatures);
no strict 'refs';
no warnings 'once';

use Carp ();
use Data::Printer;
use List::Util qw(reduce);
use Scalar::Util qw(looks_like_number blessed);

use Llama::Util qw(toHashRef);
use Llama::Parser::Result;

use Exporter 'import';
our @EXPORT_OK = qw(
  Const
  Fail
  Any
  Or
  And
  AndThen
);

# Aliases

sub Result :prototype() { 'Llama::Parser::Result' }

=pod

=head1 Combinators

=head1 Const

=cut

sub Const ($value) {
  __PACKAGE__->new(sub ($input) {
    Result->Ok(value => $value, rest => $input);
  });
}

=pod

=head2 Fail

Return a parser that fail on any input. The parser will always return an error result.

    my $parser = Fail('I will always fail');
    $parser->run('Hey!') # => Result::Error('I will always fail')

=cut

sub Fail ($message) {
  __PACKAGE__->new(sub ($input) {
    return Result->Error(message => $message);
  });
}

=pod

=head2 Any

Return a parser that succeed on any input. The parser will never return an error result.
It's also greedy in the sense that it will match the entire stream, i.e. C<$result->rest>
is always C<undef>.

    my $parser = Any;
    $parser->run('Anything is ok') # => Result::Ok('Anything is ok')

=cut

sub Any {
  state $Any = __PACKAGE__->new(sub ($input) {
    return Result->Ok(value => $input);
  });
}

=pod

=head2 Or

Return a parser that will attempt to run each parser it's given in turn until one succeeds
or they all fail. If all parsers fail the result will be the last error.

    my $a_or_b = Or(Chars('a'), Chars('b'));
    $a_or_b->parse("about") # => Result::Ok("a", "bout")
    $a_or_b->parse("bout")  # => Result::Ok("b", "out")
    $a_or_b->parse("out")   # => Result::Error

=cut

sub Or (@parsers) {
  reduce { $a->or_else($b) } @parsers;
}

=pod

=head2 AndThen

=cut

sub AndThen (@parsers) {
  reduce { $a->and_then($b) } @parsers;
}

=pod

=head2 And

    my $one_two_three = And(Num(1), Num(2), Num(3));
    $one_two_three->parse("123") # => [Result::Ok(1, "23"), Result::Ok(2, "3"), Result::Ok(3)]

=cut

sub And (@parsers) {
  __PACKAGE__->new(sub ($input) {
    my (@messages, @values, $result);

    for my $parser (@parsers) {
      $result = $parser->run($input);
      if ($result->is_ok && !@messages) {
        $input = $result->rest;
        push @values => $result->value unless $result->is_void;
      }
      push @messages => $result->message if $result->is_error;
    }

    return Result->CompositeError(messages => \@messages) if @messages;
    return Result->Ok(value => \@values, rest => $result->rest);
  });
}

=pod

=head1 Class Methods

=cut

sub new ($class, $sub) {
  return bless $sub => $class;
}

=pod

=head1 Instance Methods

=cut

use overload
  '|'  => sub{shift->or_else(shift)},
  '>>' => sub{shift->and_then(shift)};

sub run ($self, $input) {
  return $self->($input);
}

*parse = \&run;

sub parse_or_die ($self, $input) {
  my $result = $self->parse($input);
  Carp::confess "ParserError: " . $result->message . " while parsing " . np($input)
    if $result->is_error;
  return $result;
}

sub is_valid ($self, $input) {
  return $self->parse($input)->is_ok;
}

sub validate ($self, $input) {
  return $self->parse_or_die($input)->value;
}

sub and_then ($self, $other) {
  return $self->__name__->new(sub ($input) {
    my $result = $self->run($input);
    return $result if $result->is_error;

    $other->run($result->rest);
  });
}

sub or_else ($self, $other) {
  return $self->__name__->new(sub ($input) {
    my $result = $self->run($input);
    return $result unless $result->is_error;

    $other->run($input);
  });
}

sub Llama::Parser::map ($self, $cb) {
  return $self->bind(sub ($input) { Const($cb->($input)) });
}

sub Llama::Parser::and ($self, $other) {
  return $self->bind(sub { $other });
}

sub Llama::Parser::bind ($self, $cb) {
  return $self->__name__->new(sub ($input) {
    my $result = $self->parse($input);
    return $result if $result->is_error;

    $cb->($result->value)->parse($result->rest);
  });
}

1;
