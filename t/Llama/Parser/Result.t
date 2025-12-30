package Llama::Parser::Result::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Parser::Result';
require_ok $described_class;

subtest "${described_class}::Ok - is_terminal" => sub {
  ok $described_class->Ok(rest => "")->is_terminal;
  ok $described_class->Ok(rest => undef)->is_terminal;
  ok $described_class->Ok(rest => [])->is_terminal;
  ok $described_class->Ok(rest => {})->is_terminal;

  ok !$described_class->Ok(rest => "hey")->is_terminal;
  ok !$described_class->Ok(rest => "0")->is_terminal;
  ok !$described_class->Ok(rest => [1])->is_terminal;
  ok !$described_class->Ok(rest => {a => 1})->is_terminal;
};

done_testing;
