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
  });
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

$described_class->import('Or');

subtest "Or" => sub {
  my $result;

  my $a_or_b = Or(Chars('a'), Chars('b'));
  my $b_or_a = Or(Chars('b'), Chars('a'));

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

  $result = $z->parse($input);
  is $result->value => "z";
  is $result->rest  => $input;
};

$described_class->import('Fail');

subtest "Fail" => sub {
  my $result;

  my $error = Fail("I don't know what to do");

  $result = $error->parse($input);
  is $result->message => "I don't know what to do";
};

$described_class->import('Any');

subtest "Any" => sub {
  my $result;

  my $get_em = Any();

  $result = $get_em->parse($input);
  is $result->value => $input;
  is $result->rest => undef;
};

$described_class->import('And');

subtest "And" => sub {
  my $result;

  my $all = And(Chars('a'), Chars('b'), Chars('c'));

  $result = $all->parse($input);
  is_deeply $result->value => [qw(a b c)];
  is $result->rest => "de";
};

done_testing;
