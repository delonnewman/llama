package Llama::Parser;
use Llama::Prelude qw(+Base::Code :signatures);
no strict 'refs';
no warnings 'once';

use List::Util qw(reduce);
use Scalar::Util qw(looks_like_number);
use Llama::Parser::Result;

#
# Parser Class Methods
#

sub coerce ($val) {
  return $val if ref $val && $val->isa('Llama::Parser');

  die "Cannot coerce value to parser: " . (defined $val ? ref $val : 'undef');
}

#
# Parser Instance Methods
#

use overload
  '|'  => 'or_else',
  '>>' => 'and_then';

*run = \&Llama::Base::Code::call;

sub and_then ($self, $other) {
  return $self->__name__->new(sub ($input) {
    my $result1 = $self->run($input);
    return $result1 if $result1->isa('Llama::Parser::Result::Error');

    $other->run($result1->rest // '');
  });
}

sub or_else ($self, $other) {
  return $self->__name__->new(sub ($input) {
    my $result1 = $self->run($input);
    return $result1 unless $result1->isa('Llama::Parser::Result::Error');

    $other->run($input);
  });
}

#
# Functions
#

sub choice (@parsers) {
  reduce { $a | $b } @parsers;
}

sub any_of (@parsers) {
  map {  } @parsers;
}

1;
