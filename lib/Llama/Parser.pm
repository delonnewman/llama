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
  reduce { $a->or_else($b) } @parsers;
}

sub any_of (@parsers) {
  choice(map { __PACKAGE__->Literal($_) } @parsers);
}

#
# Parser Class Methods
#

sub new ($class, $sub) {
  return bless $sub => $class;
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

    Result->Error(message => "is not defined");
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

    Result->Error(message => "is not a valid number got ". np($input));
  });
}

sub Literal ($class, $val)  {
  $class->__name__->new(sub ($input) {
    return Result->Ok(value => $input) if defined($input) && $input eq $val;

    Result->Error(message => "expected literal " . np($val) . " got " . np($input));
  });
}

sub Array ($class, $parser = $class->Any) {
  $class->__name__->new(sub ($input) {
    return Result->Error(message => "only array references are valid instead got: " . np($input))
      if ref($input) ne 'ARRAY';

    my @results = map { $parser->run($_) } @$input;
    my @errors  = grep { $_->is_error } @results;

    if (@errors) {
      my $i = 0;
      return Result->Error(message => join("; " => map { "index " . $i++ . " " . $_->message } @errors))
    }

    return Result->Ok(value => [map { $_->value } @results]);
  });
}

sub HasKey ($class, $key, $value = $class->Defined) {
  my $parser = $class->MayHaveKey($key, $value);
  $class->__name__->new(sub ($input) {
    my $result = $parser->run($input);
    return Result->Error(message => "key " . np($key) . " is missing")
      if $result->is_ok && !defined $result->value;

    return $result;
  });
}

sub MayHaveKey ($class, $key, $value = $class->Defined) {
  $class->__name__->new(sub ($input) {
    return Result->Error(message => "only hash references are valid instead got: " . np($input))
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

sub Keys ($class, %schema) {
  $class->_keys('HasKey', %schema);
}
*RequiredKeys = \&Keys;

sub OptionalKeys ($class, %schema) {
  $class->_keys('MayHaveKey', %schema);
}

sub _keys ($class, $method, %schema) {
  my @parsers = map { $class->MayHaveKey($_ => $schema{$_}) } keys %schema;
  $class->__name__->new(sub ($input) {
    my (@errors, %value);

    my $rest = $input;
    for my $parser (@parsers) {
      last unless $rest;
      my $result = $parser->run($rest);
      if ($result->is_ok) {
        $value{$result->value->[0]} = $result->value->[1] if $result->value;
        $rest = $result->rest;
      }
      else {
        push @errors => $result;
      }
    }

    return Result->Error(message => join("; ", map { $_->message } @errors)) if @errors;
    return Result->Ok(value => \%value, rest => $rest);
  });
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
