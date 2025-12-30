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

subtest "parse & parse_or_die" => sub {
  my $input = "abcde";
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

done_testing;
