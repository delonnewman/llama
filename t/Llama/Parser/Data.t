package Llama::Parser::Data::Test;
use Llama::Test::TestSuite;
use Llama::Test::Helpers qw(parse_ok parse_error_ok error_ok result_ok);

use Llama::Util qw(toHashRef);

my $package = 'Llama::Parser::Data';
require_ok $package;

$package->import('Undef');

subtest "${package}::Undef" => sub {
  is Undef()->name => 'Llama::Parser::Data::Undef';
  
  parse_ok Undef() => undef, undef;

  parse_error_ok Undef() => 1234;
  parse_error_ok Undef() => 'some string';
  parse_error_ok Undef() => [];
  parse_error_ok Undef() => {};
  parse_error_ok Undef() => '';
};

$package->import('Defined');

subtest "${package}::Defined" => sub {
  is Defined()->name => 'Llama::Parser::Data::Defined';

  parse_error_ok Defined() => undef;

  parse_ok Defined() => 1234   => 1234;
  parse_ok Defined() => '1234' => '1234';
  parse_ok Defined() => 'hey'  => 'hey';
  parse_ok Defined() => []     => [];
  parse_ok Defined() => {}     => {};
  parse_ok Defined() => ''     => '';
};

$package->import('Bool', 'True', 'False');

subtest "${package}::Bool" => sub {
  is Bool()->name  => 'Llama::Parser::Data::Bool';
  is True()->name  => 'Llama::Parser::Data::True';
  is False()->name => 'Llama::Parser::Data::False';

  parse_ok False() =>  0  => !!0;
  parse_ok False() => '0' => !!0;
  parse_ok False() =>  '' => !!0;
  parse_ok False() => undef, !!0;

  parse_error_ok False() => '023';
  parse_error_ok False() => 'hey';

  parse_ok True() =>  1  => !!1;
  parse_ok True() => '1' => !!1;

  parse_error_ok True() => 123;
  parse_error_ok True() => 'hey';

  parse_ok Bool() =>  0  => !!0;
  parse_ok Bool() => '0' => !!0;
  parse_ok Bool() =>  '' => !!0;
  parse_ok Bool() => undef, !!0;

  parse_ok Bool() =>  1  => !!1;
  parse_ok Bool() => '1' => !!1;

  parse_error_ok Bool() => 'hey';
  parse_error_ok Bool() => 1234;
};

$package->import('Str');

subtest "${package}::Str" => sub {
  is Str()->name => 'Llama::Parser::Data::Str';

  parse_ok Str() =>     0 => "0";
  parse_ok Str() =>  1234 => "1234";
  parse_ok Str() => 'hey' => "hey";

  parse_error_ok Str() => [];
  parse_error_ok Str() => {};
  parse_error_ok Str() => undef;
};

subtest "${package}::Str - with parameter" => sub {
  my $hey = Str("hey");
  is $hey->name => 'Llama::Parser::Data::Str("hey")';

  parse_ok $hey => "hey" => "hey";
  parse_error_ok $hey => "hey!";
  parse_error_ok $hey => "hello";

  my $prefix_he = Str(qr/^he/);
  is $prefix_he->name => 'Llama::Parser::Data::Str(^he  (modifiers: u))';

  parse_ok $prefix_he => "hey"   => "hey";
  parse_ok $prefix_he => "hey!"  => "hey!";
  parse_ok $prefix_he => "hello" => "hello";
};

$package->import('Num');

subtest "${package}::Num" => sub {
  is Num()->name => 'Llama::Parser::Data::Num';

  parse_ok Num() =>     0  => 0;
  parse_ok Num() =>  1234  => 1234;
  parse_ok Num() => '1234' => 1234;

  parse_error_ok Num() => [];
  parse_error_ok Num() => {};
  parse_error_ok Num() => undef;
  parse_error_ok Num() => 'hey';
};

subtest "${package}::Num - with parameter" => sub {
  my $one = Num(1);
  is $one->name => 'Llama::Parser::Data::Num(1)';

  parse_ok $one => 1 => 1;
  parse_ok $one => "1" => 1;

  parse_error_ok $one => "one";
  parse_error_ok $one => "1am";
  parse_error_ok $one => "1 km";
};

$package->import('Array');

subtest "${package}::Array" => sub {
  is Array()->name => 'Llama::Parser::Data::Array';

  parse_ok Array() => []               => [];
  parse_ok Array() => [1, 2, 3]        => [1, 2, 3];
  parse_ok Array() => [qw(1 2 3)]      => [qw(1 2 3)];
  parse_ok Array() => [qw(a b c)]      => [qw(a b c)];
  parse_ok Array() => [a => 1, b => 2] => [a => 1, b => 2];

  my $nums = Array(Num());
  is $nums->name => 'Llama::Parser::Data::Array(Llama::Parser::Data::Num)';

  my $result = $nums->run([1, 2, 3]);
  parse_ok $nums => [] => [];
  parse_ok $nums => [1, 2, 3] => [1, 2, 3];
  parse_ok $nums => [qw(1 2 3)] => [1, 2, 3];

  parse_error_ok $nums => [qw(a b c)] => qr/index 0 is not a valid number got "a"/;
};

$package->import('HasKey');

subtest "${package}::HasKey" => sub {
  my $name = HasKey('name');
  is $name->name => 'Llama::Parser::Data::HasKey(name)';
  
  my $age = HasKey(age => Num());
  is $age->name =>
    'Llama::Parser::Data::HasKey(age => Llama::Parser::Data::Num)';

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
  like $result->message => qr/key "age" is not a valid number got "thirty"/;
};

$package->import('MayHaveKey');

subtest "${package}::MayHaveKey" => sub {
  my $name = MayHaveKey('name');
  is $name->name => 'Llama::Parser::Data::MayHaveKey(name)';

  my $age = MayHaveKey(age => Num());
  is $age->name =>
    'Llama::Parser::Data::MayHaveKey(age => Llama::Parser::Data::Num)';

  # Valid
  my $result = $name->run({ name => 'James', age => 34 });
  is_deeply $result->value => [name => 'James'];
  is_deeply $result->rest  => { age => 34 };

  # Missing
  $result = $name->run({ age => 56 });
  result_ok $result;

  # Undefined
  $result = $name->run({ name => undef, age => 13 });
  error_ok $result => qr/key "name" is not defined/;

  # Value Error
  $result = $age->run({ age => 'thirty' });
  error_ok $result => qr/key "age" is not a valid number got "thirty"/;
};

$package->import('Keys');

subtest "${package}::Keys" => sub {
  my $person = Keys(
    name    => Str(),
    age     => Num(),
    manager => Bool(),
  );

  like $person->name => qr/^Llama::Parser::Data::Keys\(.*\)/;
  like $person->name => qr/name => Llama::Parser::Data::Str/;
  like $person->name => qr/age => Llama::Parser::Data::Num/;
  like $person->name => qr/manager => Llama::Parser::Data::Bool/;

  my $result = $person->run({
    name    => 'Janet',
    age     => 30,
    manager => 1,
  });

  is $result->rest => undef;
  is_deeply toHashRef($result->value) => {
    name    => 'Janet',
    age     => 30,
    manager => !!1,
  };
};

$package->import('OptionalKeys');

subtest "${package}::OptionalKeys" => sub {
  my $person = OptionalKeys(
    name    => Str(),
    age     => Num(),
    manager => Bool(),
  );

  like $person->name => qr/^Llama::Parser::Data::OptionalKeys\(.*\)/;
  like $person->name => qr/name => Llama::Parser::Data::Str/;
  like $person->name => qr/age => Llama::Parser::Data::Num/;
  like $person->name => qr/manager => Llama::Parser::Data::Bool/;

  my $result = $person->run({
    name    => 'Janet',
    age     => 30,
    manager => 1,
  });

  is $result->rest => undef;
  is_deeply toHashRef($result->value) => {
    name    => 'Janet',
    age     => 30,
    manager => !!1,
  };

  $result = $person->run({
    name => 'Janet',
    age  => 30,
  });

  is_deeply toHashRef($result->value) => {
    name => 'Janet',
    age  => 30,
  };
};

$package->import('Tuple');

subtest "${package}::Tuple" => sub {
  my $nums = Tuple(Num(1), Num(2), Num(3));
  is_deeply $nums->run([1, 2, 3])->value   => [1, 2, 3];
  is_deeply $nums->run([qw(1 2 3)])->value => [1, 2, 3];

  ok $nums->run(1)->is_error;
  like $nums->run([1, 2, 3, 4])->message
    => qr/expected a sequence of 3 elements, but got 4 instead/;
  like $nums->run([1, 2])->message
    => qr/expected a sequence of 3 elements, but got 2 instead/;

  my $alpha = Tuple(Str("a"), Str("b"), Str("c"));
  is_deeply $alpha->run([qw(a b c)])->value => [qw(a b c)];
};

$package->import('Literal');

subtest "${package}::Literal" => sub {
  my $one = Literal(1);
  is $one->run("1")->value => 1;
  ok $one->run("one")->is_error;

  my $hey = Literal("Hey");
  is $hey->run("Hey")->value => "Hey";
  ok $hey->run("hey")->is_error;

  my $hey_i = Literal(qr/^Hey$/i);
  is $hey_i->run("Hey")->value => "Hey";
  is $hey_i->run("hey")->value => "hey";
  ok $hey_i->run("Hey!")->is_error;

  my $seq = Literal([1..3]);
  is_deeply $seq->run([1, 2, 3])->value   => [1, 2, 3];
  is_deeply $seq->run([qw(1 2 3)])->value => [1, 2, 3];

  my $hash = Literal({ a => 1, b => 2 });
  is_deeply toHashRef($hash->run({ a => "1", b => "2" })->value)
    => { a => 1, b => 2 };
};

$package->import('Seq');

subtest "${package}::Seq" => sub {
  parse_ok Seq() => [] => [];
  parse_ok Seq() => [1, 2, 3] => [1, 2, 3];

  my $hash   = {a => 1, b => 2, c => 3};
  my $result = Seq()->run($hash);
  is [grep { $_->[0] eq 'a' } $result->value->@*]->[0][1] => $hash->{a};
  is [grep { $_->[0] eq 'b' } $result->value->@*]->[0][1] => $hash->{b};
  is [grep { $_->[0] eq 'c' } $result->value->@*]->[0][1] => $hash->{c};

  parse_error_ok Seq() => 1;
  parse_error_ok Seq() => 'a';
  parse_error_ok Seq() => undef;
};

# $package->import('Elem');

# subtest "${package}::Elem" => sub {
#   my $nums = Elem(Num(1)) >> Elem(Num(2)) >> Elem(Num(3));
#   pass();
  
#   parse_ok $nums => [1..3]  => [1..3];
#   parse_ok $nums => [1..10] => [1..10];

#   parse_error_ok $nums => [] => [];
#   parse_error_ok $nums => [qw(a b c)];
# };

package Test::Person {
  $package->import('HashObject', 'HasKey', 'MayHaveKey', 'Str', 'Num', 'Bool');

  sub parser ($self) {
    state $parser = HashObject(
      ref($self) || $self,
      HasKey(name    => Str()),
      HasKey(age     => Num()),
      MayHaveKey(manager => Bool()),
    );
  }

  sub new ($class, %attributes) {
    return $class->parser->parse(\%attributes);
  }

  sub name    ($self) { $self->{name} }
  sub age     ($self) { $self->{age} }
  sub manager ($self) { $self->{manager} }
}

subtest "${package}::HashObject" => sub {
  my $person = Test::Person->new(
    name    => 'Jake',
    age     => 19,
    manager => 0,
  );

  like $person->parser->name => qr/^Test::Person\(.+\)/;
  like $person->parser->name => qr/HasKey\(name => Llama::Parser::Data::Str\)/;
  like $person->parser->name => qr/HasKey\(age => Llama::Parser::Data::Num\)/;
  like $person->parser->name =>
    qr/MayHaveKey\(manager => Llama::Parser::Data::Bool\)/;

  isa_ok $person      => 'Test::Person';
  is $person->name    => 'Jake';
  is $person->age     => 19;
  is $person->manager => !!0;

  throws { Test::Person->new(name => 'Katie', age => 'five') } qr/ArgumentError:/
};

done_testing;
