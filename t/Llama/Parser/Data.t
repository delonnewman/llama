package Llama::Parser::Data::Test;
use Llama::Test::TestSuite;

use Llama::Util qw(toHashRef);

my $package = 'Llama::Parser::Data';
require_ok $package;

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

sub parse_error_ok ($parser, $val) {
  my $result = $parser->run($val);

  isa_ok $result => "Llama::Parser::Result" => np($val);
  isa_ok $result => "Llama::Parser::Result::Error" => np($val);
}

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

$package->import('Bool');

subtest "${package}::Bool" => sub {
  is Bool()->name => 'Llama::Parser::Data::Bool';

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
  parse_ok Array() => []               => [];
  parse_ok Array() => [1, 2, 3]        => [1, 2, 3];
  parse_ok Array() => [qw(a b c)]      => [qw(a b c)];
  parse_ok Array() => [a => 1, b => 2] => [a => 1, b => 2];

  my $nums = Array(Num());

  my $result = $nums->run([1, 2, 3]);
  is_deeply $result->value => [1, 2, 3];

  $result = $nums->run([qw(a b c)]);
  ok $result->is_error;
  like $result->message => qr/index 0 is not a valid number got "a"/;
};

$package->import('HasKey');

subtest "${package}::HasKey" => sub {
  my $name = HasKey('name');
  my $age  = HasKey(age => Num());

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
  my $age  = MayHaveKey(age => Num());

  # Valid
  my $result = $name->run({ name => 'James', age => 34 });
  is_deeply $result->value => [name => 'James'];
  is_deeply $result->rest  => { age => 34 };

  # Missing
  $result = $name->run({ age => 56 });
  ok $result->is_ok;

  # Undefined
  $result = $name->run({ name => undef, age => 13 });
  like $result->message => qr/key "name" is not defined/;

  # Value Error
  $result = $age->run({ age => 'thirty' });
  like $result->message => qr/key "age" is not a valid number got "thirty"/;
};

$package->import('Keys');

subtest "${package}::Keys" => sub {
  my $person = Keys(
    name    => Str(),
    age     => Num(),
    manager => Bool(),
  );

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

  $result = $person->parse_or_die({
    name => 'Janet',
    age  => 30,
  });

  is_deeply toHashRef($result->value) => {
    name => 'Janet',
    age  => 30,
  };
};

package Person {
  $package->import('HashObject', 'HasKey', 'Str', 'Num', 'Bool');

  our $SCHEMA = HashObject(
    __PACKAGE__,
    HasKey(name    => Str()),
    HasKey(age     => Num()),
    HasKey(manager => Bool()),
  );

  sub new ($class, %attributes) {
    my $result = $SCHEMA->run(\%attributes);
    die "ArgumentError: " . $result->message if $result->is_error;
    return $result->value;
  }

  sub name    ($self) { $self->{name} }
  sub age     ($self) { $self->{age} }
  sub manager ($self) { $self->{manager} }
}

subtest "${package}::HashObject" => sub {
  my $person = Person->new(
    name    => 'Jake',
    age     => 19,
    manager => 0,
  );

  isa_ok $person      => 'Person';
  is $person->name    => 'Jake';
  is $person->age     => 19;
  is $person->manager => !!0;

  throws { Person->new(name => 'Katie', age => 'five') } qr/ArgumentError:/
};

done_testing;
