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
      is_deeply $result->value => $args[0], "expected: " . np($args[0]) . ', got: ' . np($result->value);
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

subtest "${described_class}::Undef" => sub {
  parse_ok Undef => undef, undef;

  parse_error_ok Undef => 1234;
  parse_error_ok Undef => 'some string';
  parse_error_ok Undef => [];
  parse_error_ok Undef => {};
  parse_error_ok Undef => '';
};

subtest "${described_class}::Defined" => sub {
  parse_error_ok Defined => undef;

  parse_ok Defined => 1234   => 1234;
  parse_ok Defined => '1234' => '1234';
  parse_ok Defined => 'hey'  => 'hey';
  parse_ok Defined => []     => [];
  parse_ok Defined => {}     => {};
  parse_ok Defined => ''     => '';
};

subtest "${described_class}::Any" => sub {
  parse_ok Any => undef, undef;
  parse_ok Any => 1234   => 1234;
  parse_ok Any => '1234' => '1234';
  parse_ok Any => 'hey'  => 'hey';
  parse_ok Any => []     => [];
  parse_ok Any => {}     => {};
  parse_ok Any => ''     => '';
};

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
  parse_ok ArrayOf => []               => [];
  parse_ok ArrayOf => [1, 2, 3]        => [1, 2, 3];
  parse_ok ArrayOf => [qw(a b c)]      => [qw(a b c)];
  parse_ok ArrayOf => [a => 1, b => 2] => [a => 1, b => 2];
};

subtest "${described_class}::HasKey" => sub {
  my $name = $described_class->HasKey('name');
  my $age  = $described_class->HasKey(age => $described_class->Num);

  # Valid
  my $result = $name->run({ name => 'James', age => 34 });
  is_deeply $result->value => [name => 'James'];
  is_deeply $result->rest  => { age => 34 };

  # Missing
  $result = $name->run({ age => 56 });
  like $result->message => qr/key "name" is missing/;

  # Undefined
  $result = $name->run({ name => undef, age => 13 });
  like $result->message => qr/key "name" is not defined/;

  # Value Error
  $result = $age->run({ age => 'thirty' });
  like $result->message => qr/key "age" is not a valid number, got "thirty"/;
};

subtest "${described_class}::Keys" => sub {
  my $person = $described_class->Keys(
    name    => $described_class->Str,
    age     => $described_class->Num,
    manager => $described_class->Bool,
  );

  my $result = $person->run({
    name    => 'Janet',
    age     => 30,
    manager => 1,
  });

  is $result->rest => undef;
  is_deeply $result->value => {
    name    => 'Janet',
    age     => 30,
    manager => !!1,
  };
};

done_testing;
