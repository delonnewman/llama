package Llama::Parser;
use Llama::Prelude qw(+Base :signatures);
no strict 'refs';
no warnings 'once';

use Data::Printer;
use List::Util qw(reduce);
use Scalar::Util qw(looks_like_number);

use Llama::Parser::Result;
sub Result :prototype() { 'Llama::Parser::Result' }

use Exporter 'import';
our @EXPORT_OK = qw(choice any_of);

#
# Exported Functions
#

sub choice (@parsers) {
  reduce { $a | $b } @parsers;
}

sub any_of (@parsers) {
  choice(map { __PACKAGE__->coerce($_) } @parsers);
}

#
# Parser Class Methods
#

sub new ($class, $sub) {
  return bless $sub => $class;
}

sub coerce ($val) {
  return $val if ref $val && $val->isa('Llama::Parser');

  die "Cannot coerce value to parser: " . (defined $val ? ref $val : 'undef');
}

sub Undef ($class) {
  state $Undef = $class->__name__->new(sub ($input) {
    return Result->Ok(value => $input) unless defined $input;

    Result->Error(message => np($input) . " is not undefined");
  });
}

sub Defined ($class) {
  state $Defined = $class->__name__->new(sub ($input) {
    return Result->Ok(value => $input) if defined $input;

    Result->Error(message => np($input) . " is not efined");
  });
}

sub Any ($class) {
  state $Any = $class->__name__->new(sub ($input) {
    return Result->Ok(value => $input);
  });
}

sub Bool ($class) {
  state $Bool = $class->__name__->new(sub ($input) {
    return Result->Ok(value => !!0) if !$input;
    return Result->Ok(value => !!1) if $input eq '1';

    Result->Error(message => np($input) . " is not a valid boolean value");
  });
}

sub Str ($class) {
  state $Str = $class->__name__->new(sub ($input) {
    return Result->Ok(value => "$input") if defined($input) && ref(\$input) eq 'SCALAR';

    Result->Error(message => np($input) . " is not a valid string value");
  });
}

sub Num ($class) {
  state $Num = $class->__name__->new(sub ($input) {
    return Result->Ok(value => 0+$input) if defined($input) && looks_like_number($input);

    Result->Error(message => np($input) . " is not a valid number value");
  });
}

sub ArrayOf ($class, $parser = $class->Any) {
  $class->__name__->new(sub ($input) {
    return Result->Error(message => "only array references are valid instead got: " . np($input))
      if ref($input) ne 'ARRAY';

    my @results = map { $parser->run($_) } @$input;
    my @errors  = grep { $_->isa('Llama::Parser::Result::Error') } @results;
    return Result->Error(message => join("; ", map { $_->message } @errors)) if @errors;

    return Result->Ok(value => [map { $_->value } @results]);
  });
}

#
# Parser Instance Methods
#

use overload
  '|'  => 'or_else',
  '>>' => 'and_then';

sub run ($self, $input) {
  return $self->($input);
}

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

1;
