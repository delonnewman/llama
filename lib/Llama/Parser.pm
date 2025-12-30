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
our @EXPORT_OK = qw(choice any_of collect);

# Aliases

sub Result :prototype() { 'Llama::Parser::Result' }

#
# Exported Combinators
#

sub choice (@parsers) {
  reduce { $a->or_else($b) } @parsers;
}

sub any_of (@parsers) {
  choice(map { __PACKAGE__->coerce($_) } @parsers);
}

=pod

=head2 collect

    my $parser = collect(Num(1), Num(2), Num(3));

=cut

sub collect (@parsers) {
  my $xformer = shift @parsers unless blessed($parsers[0]);

  __PACKAGE__->new(sub ($input) {
    my (@messages, @values);

    for my $parser (@parsers) {
      my $result = $parser->run($input);
      if ($result->is_ok && !@messages) {
        $input = $result->rest;
        push @values => $result->value;
      }
      push @messages => $result->message if $result->is_error;
    }

    return Result->CompositeError(messages => \@messages) if @messages;

    my $val = defined $xformer ? $xformer->(@values) : \@values;
    return Result->Ok(value => $val);
  });
}

#
# Parser Class Methods
#

sub new ($class, $sub) {
  return bless $sub => $class;
}

#
# Parser Instance Methods
#

use overload
  '|'  => sub{shift->or_else(shift)},
  '>>' => sub{shift->and_then(shift)};

sub run ($self, $input) {
  return $self->($input);
}

*parse = \&run;

sub parse_or_die ($self, $input) {
  my $result = $self->parse($input);
  Carp::confess "ParserError: while parsing " . np($input) . ' ' . $result->message if $result->is_error;
  return $result;
}

sub and_then ($self, $other) {
  return $self->__name__->new(sub ($input) {
    my $result1 = $self->run($input);
    return $result1 if $result1->is_error;

    $other->run($result1->rest);
  });
}

sub or_else ($self, $other) {
  return $self->__name__->new(sub ($input) {
    my $result1 = $self->run($input);
    return $result1 unless $result1->is_error;

    $other->run($input);
  });
}

1;
