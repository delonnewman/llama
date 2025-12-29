package Llama::Parser::Data;
use Llama::Prelude qw(:signatures);
no strict 'refs';
no warnings 'once';

use Data::Printer;
use Scalar::Util qw(looks_like_number blessed);

use Llama::Parser qw(collect choice);
use Llama::Parser::Result;

use Exporter 'import';
our @EXPORT_OK = qw(
  Undef
  Defined
  Any
  Bool
  Str
  Num
);


=pod

=head1 NAME

Llama::Parser::Data - A collection of parsers that are suitable for parsing
arbitrary Perl data structures.

=head1 SYNOPSIS

  use Llama::Parser::Data qw(HashObject HasKey MayHaveKey);

  my $parser = HashObject('Employee',
    HasKey(name => Str),
    HasKey(age  => Num),
    MayHaveKey(manager => Bool),
  );

  my $result = $parser->run({
    name    => "Alice",
    age     => 30,
    manager => '1',
  });

  if ($result->is_ok) {
    my $obj = $result->value; # An instance of Employee
  } else {
    die "Parsing failed: " . $result->message;
  }

=head1 SEE ALSO

L<Llama::Parser>

=cut

sub Result :prototype() { 'Llama::Parser::Result' }
sub Parser :prototype() { 'Llama::Parser' }

=pod

=head1 FUNCTIONS

=head2 Undef

Return a parser that succeeds if the input is undefined, otherwise
it returns an error result.

    my $parser = Undef;
    $parser->run(undef); # => Result::Ok(undef)
    $parser->run(123);   # => Result::Error('is not undefined got 123')

=cut

sub Undef :prototype() {
  state $Undef = Parser->new(sub ($input) {
    return Result->Ok(value => $input) unless defined $input;

    Result->Error(message => "is not undefined got " . np($input));
  });
}

=pod

=head2 Defined

Return a parser that succeeds if the input is not undefined, otherwise
it returns an error result.

    my $parser = Defined;
    $parser->run(undef); # => Result::Error('is not defined')
    $parser->run(123);   # => Result::Ok(123)

=cut

sub Defined :prototype() {
  state $Defined = Parser->new(sub ($input) {
    return Result->Ok(value => $input) if defined $input;

    Result->Error(message => "is not defined");
  });
}

=pod

=head2 Any

Return a parser that succeed on any input. The parser will never return an error result.

    my $parser = Any;
    $parser->run('Anything is ok') # => Result::Ok('Anything is ok')

=cut

sub Any {
  state $Any = Parser->new(sub ($input) {
    return Result->Ok(value => $input);
  });
}

sub AnyOf (@parsers) {
  choice(map { Parser->coerce($_) } @parsers);
}

sub AnyBut ($parser) {

}

sub AnyIf ($predicate) {

}


=pod

=head2 Fail

Return a parser that fail on any input. The parser will always return an error result.

    my $parser = Fail('I will always fail');
    $parser->run('Hey!') # => Result::Error('I will always fail')

=cut

sub Fail ($message) {
  Parser->new(sub ($input) {
    return Result->Error(message => $message);
  });
}

=pod

=head2 Bool

=cut

sub Bool :prototype() {
  state $Bool = Parser->new(sub ($input) {
    return Result->Ok(value => !!0) if !$input;
    return Result->Ok(value => !!1) if $input eq '1';

    Result->Error(message => np($input) . " is not a valid boolean value");
  });
}

=pod

=head2 Str

=cut

sub Str ($pattern = undef) {
  Parser->new(sub ($input) {
    return Result->Error(message => np($input) . " is not a valid string value")
      unless defined($input) && ref(\$input) eq 'SCALAR';

    return Result->Ok(value => "$input") unless defined $pattern;

    if (ref $pattern eq 'Regexp') {
      return Result->Ok(value => "$input") if $input =~ $pattern;
      return Result->Error(message => np($input) . " does not match pattern " . np($pattern));
    }

    return Result->Ok(value => "$input") if $input eq $pattern;
    return Result->Error(message => np($input) . " does not equal " . np($pattern));
  });
}

=pod

=head2 Num

Return a parser that succeeds if the input is a number. If a literal
is given as an argument, the parser will only succeed if the input is
numerically equal to the literal, otherwise the result will be an error.
In all cases if the input is successful it will be coerced into a number.

    my $num = Num();
    $num->run(1234); # => Result::Ok(1234)
    $num->run('1234'); # => Result::Error('is not a valid number got "1234"')

    my $parser = choice(Num(1), Num(2), Num(3));
    $parser->run(1); # => Result::Ok(1)
    $parser->run(2); # => Result::Ok(2)
    $parser->run(3); # => Result::Ok(3)
    $parser->run(4); # => Result::Error('4 is not 1 or 2 or 3')

=cut

sub Num ($literal = undef) {
  state $Num = Parser->new(sub ($input) {
    return Result->Error(message => "is not a valid number got ". np($input))
      unless defined($input) && looks_like_number($input);

    return Result->Ok(value => 0+$input) unless defined $literal;
    return Result->Ok(value => 0+$input) if $input == $literal;

    Result->Error(message => np($input) . " does not equal " . np($literal));
  });
}

# TODO: consider supporting booleans on newer Perls > 5.36
sub Literal ($val)  {
  my $ref = ref $val;
  return collect(map { Literal($_) } @$val)
    if $ref eq 'ARRAY';

  return Keys(map { $_ => Literal($val->{$_}) } keys %$val)
    if $ref eq 'HASH';

  return Num($val) if looks_like_number($val);
  return Str($val);
}

sub Array ($parser = undef) {
  Parser->new(sub ($input) {
    return Result->Error(message => "only array references are valid instead got " . np($input))
      if ref $input ne 'ARRAY';

    return Result->Ok(value => $input) unless $parser;

    my (@messages, @values);
    my $i = 0;

    for my $val (@$input) {
      my $result = $parser->run($val);
      if ($result->is_ok && !@messages) {
        $input = $result->rest;
        push @values => $result->value;
      }
      if ($result->is_error) {
        push @messages => "index " . $i++ . " " . $result->message;
      }
    }

    return Result->CompositeError(messages => \@messages) if @messages;
    return Result->Ok(value => \@values);
  });
}

sub HasKey ($key, $value = Defined) {
  my $parser = MayHaveKey($key, $value);

  Parser->new(sub ($input) {
    my $result = $parser->run($input);

    return Result->Error(message => "key " . np($key) . " is missing")
      if $result->is_ok && !defined $result->value;

    return $result;
  });
}

sub MayHaveKey ($key, $value = Defined) {
  Parser->new(sub ($input) {
    return Result->Error(message => "only hash references are valid instead got " . np($input))
      if ref($input) ne 'HASH';

    return Result->Ok(rest => $input) unless exists $input->{$key};

    my $result = $value->run($input->{$key});
    return Result->Error(message => "key " . np($key) . " " . $result->message) if $result->is_error;

    my @keys = grep { $_ ne $key } keys %$input;
    my %rest = %{$input}{@keys};
    my $pair = [$key, $result->value];

    return Result->Ok(value => $pair, rest => %rest ? \%rest : undef);
  });
}

sub Keys (%schema) {
  collect(map { HasKey($_ => $schema{$_}) } keys %schema);
}
*RequiredKeys = \&Keys;

sub OptionalKeys (%schema) {
  collect(map { MayHaveKey($_ => $schema{$_}) } keys %schema);
}

sub HashObject ($class_name, @parsers) {
  my $parser = collect(\&toHashRef, @parsers);

  Parser->new(sub ($input) {
    my $result = $parser->run($input);
    return $result if $result->is_error;

    my $obj = bless $result->value => $class_name;
    return Result->Ok(value => $obj);
  });
}

1;
