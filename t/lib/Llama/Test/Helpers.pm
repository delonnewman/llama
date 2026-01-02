package Llama::Test::Helpers;
use Llama::Prelude qw(:signatures);
use Llama::Test::TestSuite;

use Exporter 'import';
our @EXPORT_OK = qw(
  parse_ok
  parse_error_ok
  error_ok
  result_ok
);

sub result_ok ($result, %options) {
  my $name = $options{-name} // '';

  isa_ok $result => "Llama::Parser::Result" => $name;
  isa_ok $result => "Llama::Parser::Result::Ok" => $name;

  my $msg = 'result is ok';
  $msg .= ": $name" if $name;

  ok $result->is_ok => $msg;
}

sub parse_ok ($parser, $val, @args) {
  my $result = $parser->run($val);

  result_ok $result, -name => np($val);

  if (@args > 0) {
    if (ref $args[0]) {
      is_deeply $result->value => $args[0] =>
        "expected: " . np($args[0]) . ', got: ' . np($result->value);
    } else {
      is $result->value => $args[0];
    }
  }

  is $result->rest => $args[1] if @args > 1;
}

sub error_ok ($result, $pattern = undef, %options) {
  my $name = $options{-name} // '';

  isa_ok $result => "Llama::Parser::Result" => $name;
  isa_ok $result => "Llama::Parser::Result::Error" => $name;

  my $msg = 'result is error';
  $msg .= ": $name" if $name;

  ok $result->is_error => $msg;
  like $result->message => $pattern if $pattern;
}

sub parse_error_ok ($parser, $val, $pattern = undef) {
  my $result = $parser->run($val);
  error_ok $result, $pattern, -name => np($val);
}

1;
