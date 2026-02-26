package Llama::Parser::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Parser';
require_ok $described_class;

my $result_class = 'Llama::Parser::Result';
require_ok $result_class;

sub Result :prototype() { 'Llama::Parser::Result' }

sub Chars ($chars) {
  Llama::Parser->new(sub ($input) {
    return Result->Error(message => "input shouldn't be an empty or undef")
      if $input eq '';

    $input =~ s/^($chars)//;
    return Result->Error(message => "input doesn't start with " . np($chars))
      unless $1;

    return Result->Ok(value => $1, rest => $input);
  } => 'Test::Chars(' . np($chars) . ')');
}

my $input = "abcde";

subtest "parse & parse_or_die" => sub {
  my $result;

  my $a = Chars('a');
  my $b = Chars('b');

  $result = $a->parse($input);
  is $result->value => "a";
  is $result->rest  => "bcde";

  $result = $b->parse($input);
  is $result->message => "input doesn't start with \"b\"";

  throws { $b->parse_or_die($input) } qr/ParseError:/;
};

subtest ">>" => sub {
  my $all =
    Chars('a') >>
    Chars('b') >>
    Chars('c') >>
    Chars('d') >>
    Chars('e');

  my $result = $all->run($input);
  is_deeply $result->toArrayRef => ['a', 'b', 'c', 'd', 'e'];
  is $result->rest => '';

  $result = $all->parse('ac');
  ok $result->is_error;
};

subtest "|" => sub {
  my $any =
    Chars('a') |
    Chars('b') |
    Chars('c') |
    Chars('d') |
    Chars('e');

  my $result = $any->parse_or_die($input);
  is_deeply $result->value => 'a';
  is $result->rest => 'bcde';

  $result = $any->parse('fab');
  ok $result->is_error;
};

subtest "is_valid" => sub {
  my $hi = Chars('h') >> Chars('i');

  ok  $hi->is_valid("hi");
  ok !$hi->is_valid('Hi');
};

$described_class->import('Or');

subtest "Or" => sub {
  my $result;

  my $a_or_b = Or(Chars('a'), Chars('b'));
  my $b_or_a = Or(Chars('b'), Chars('a'));

  is $a_or_b->name =>
    'Llama::Parser::Or(Test::Chars("a"), Test::Chars("b"))';

  $result = $a_or_b->parse($input);
  is $result->value => "a";
  is $result->rest  => "bcde";

  $result = $b_or_a->parse($input);
  is $result->value => "a";
  is $result->rest  => "bcde";
};

$described_class->import('Const');

subtest "Const" => sub {
  my $result;

  my $z = Const('z');
  is $z->name  => 'Llama::Parser::Const("z")';

  $result = $z->parse($input);
  is $result->value => "z";
  is $result->rest  => $input;
};

$described_class->import('Fail');

subtest "Fail" => sub {
  my $result;

  my $message = "Fail!";
  my $error = Fail($message);
  is $error->name => "Llama::Parser::Fail(\"$message\")";

  $result = $error->parse($input);
  is $result->message => $message;
};

$described_class->import('Any');

subtest "Any" => sub {
  my $result;

  my $get_em = Any();
  is $get_em->name => 'Llama::Parser::Any';

  $result = $get_em->parse($input);
  is $result->value => $input;
  is $result->rest => undef;
};

$described_class->import('And');

subtest "And" => sub {
  my $result;

  my $all = And(Chars('a'), Chars('b'), Chars('c'));
  is $all->name =>
    'Llama::Parser::And(Test::Chars("a"), Test::Chars("b"), Test::Chars("c"))';

  $result = $all->parse_or_die($input);
  is_deeply $result->value => [qw(a b c)];
  is $result->rest => "de";
};

subtest "And - early return" => sub {
  my $result;

  my $all = And(
    Chars('a'),
    Chars('b'),
    Chars('c'),
    Chars('d'),
    Chars('e'),
    Chars('f')
  );

  $result = $all->parse_or_die($input);
  is_deeply $result->value => [qw(a b c d e)];
  is $result->rest => '';
};

done_testing;
