package Llama::Base::Test;
use Llama::Test::TestSuite;
use Llama::Prelude qw(:signatures);
use Data::Printer;

my $described_class = 'Llama::Parser';
require_ok $described_class;

sub parse_ok ($type, $val, @args) {
  my $result = $described_class->$type->run($val);
  my $valStr = np($val);

  isa_ok $result => "$described_class\::Result" => "$type => $valStr";
  isa_ok $result => "$described_class\::Result\::Ok" => "$type => $valStr";

  if (@args > 0) {
    if (ref $args[0]) {
      is_deeply $result->value => $args[0];
    } else {
      is $result->value => $args[0];
    }
  }

  is $result->rest  => $args[1] if @args > 1;
}

sub parse_error_ok ($type, $val) {
  my $result = $described_class->$type->run($val);
  my $valStr = np($val);

  isa_ok $result => "$described_class\::Result" => "$type => $valStr";
  isa_ok $result => "$described_class\::Result\::Error" => "$type => $valStr";
}

subtest "${described_class}::Bool" => sub {
  parse_ok Bool =>  0  => !!0;
  parse_ok Bool => '0' => !!0;
  parse_ok Bool =>  '' => !!0;
  parse_ok Bool => undef, !!0;

  parse_ok Bool =>  1  => !!1;
  parse_ok Bool => '1' => !!1;

  parse_error_ok Bool => 'hey';
  parse_error_ok Bool => 1234;
};

subtest "${described_class}::Str" => sub {
  parse_ok Str =>     0 => "0";
  parse_ok Str =>  1234 => "1234";
  parse_ok Str => 'hey' => "hey";

  parse_error_ok Str => [];
  parse_error_ok Str => {};
  parse_error_ok Str => undef;
};

subtest "${described_class}::Num" => sub {
  parse_ok Num =>     0  => 0;
  parse_ok Num =>  1234  => 1234;
  parse_ok Num => '1234' => 1234;

  parse_error_ok Num => [];
  parse_error_ok Num => {};
  parse_error_ok Num => undef;
  parse_error_ok Num => 'hey';
};

subtest "${described_class}::ArrayOf" => sub {
  parse_ok ArrayOf => []        => [];
  parse_ok ArrayOf => [1, 2, 3] => [1, 2, 3];
};

done_testing;
