package Llama::Test::Helpers;
use Llama::Prelude qw(:signatures);
use Llama::Test::TestSuite;

use Exporter 'import';
our @EXPORT_OK = qw(parse_ok parse_error_ok);

sub parse_ok ($parser, $val, @args) {
  my $result = $parser->run($val);

  isa_ok $result => "Llama::Parser::Result" => np($val);
  isa_ok $result => "Llama::Parser::Result::Ok" => np($val);

  if (@args > 0) {
    if (ref $args[0]) {
      is_deeply $result->value => $args[0] =>
        "expected: " . np($args[0]) . ', got: ' . np($result->value);
    } else {
      is $result->value => $args[0];
    }
  }

  is $result->rest  => $args[1] if @args > 1;
}

sub parse_error_ok ($parser, $val, $pattern = undef) {
  my $result = $parser->run($val);

  isa_ok $result => "Llama::Parser::Result" => np($val);
  isa_ok $result => "Llama::Parser::Result::Error" => np($val);
  like $result->message => $pattern if $pattern;
}

1;
