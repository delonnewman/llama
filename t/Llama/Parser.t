package Llama::Base::Test;
use Llama::Test::TestSuite;
use Llama::Prelude qw(:signatures);

my $described_class = 'Llama::Parser';
require_ok $described_class;

sub result_ok ($result, @args) {
  isa_ok $result => "$described_class\::Result";
  isa_ok $result => "$described_class\::Result\::Ok";
  is $result->value => $args[0] if @args > 0;
  is $result->rest  => $args[1] if @args > 1;
}

sub result_error_ok ($result) {
  isa_ok $result => "$described_class\::Result";
  isa_ok $result => "$described_class\::Result\::Error";
}

subtest "$described_class - Bool" => sub {
  result_ok $described_class->Bool->run(0)     => !!0;
  result_ok $described_class->Bool->run('0')   => !!0;
  result_ok $described_class->Bool->run('')    => !!0;
  result_ok $described_class->Bool->run(undef) => !!0;

  result_ok $described_class->Bool->run(1)     => !!1;
  result_ok $described_class->Bool->run('1')   => !!1;

  result_error_ok $described_class->Bool->run('hey');
  result_error_ok $described_class->Bool->run(1234);
};

done_testing;
