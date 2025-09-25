package Llama::Enum::Test;
use Llama::Test::TestSuite;
use Feature::Compat::Try;
no warnings 'experimental';

my $described_class = 'Mock::Color';
package Mock::Color {
  use Llama::Enum {
    RED   => 0,
    GREEN => 1,
    BLUE  => 2,
  };
}

sub is_all_members(@actual) {
  my @expected = (
    $described_class->RED,
    $described_class->GREEN,
    $described_class->BLUE
  );

  @actual = sort { $a <=> $b } @actual;

  is $actual[$_], $expected[$_] for 0..2;
}

subtest 'it defines a set of subtypes that map the name to a value' => sub {
  is $described_class->RED->value   => 0;
  is $described_class->GREEN->value => 1;
  is $described_class->BLUE->value  => 2;
};

subtest 'instances know their keyed name' => sub {
  is $described_class->RED->key   => 'RED';
  is $described_class->GREEN->key => 'GREEN';
  is $described_class->BLUE->key  => 'BLUE';
};

subtest 'numeric equality' => sub {
  ok $described_class->RED == $described_class->RED;
  ok $described_class->RED == 0;
  ok $described_class->RED != $described_class->BLUE;
  ok $described_class->RED != 2;
};

subtest 'string equality' => sub {
  ok $described_class->RED eq $described_class->RED;
  ok $described_class->RED eq 'rED';
  ok $described_class->RED ne $described_class->BLUE;
  ok $described_class->RED ne 'BLUE';
};

subtest 'boolean context' => sub {
  is !!$described_class->RED => 1;
  is  !$described_class->RED => '';
};

subtest 'numeric context' => sub {
  is int($described_class->RED)   => 0;
  is int($described_class->GREEN) => 1;
  is int($described_class->BLUE)  => 2;
};

subtest 'string context' => sub {
  is ''.$described_class->RED   => "$described_class(RED => 0)";
  is ''.$described_class->GREEN => "$described_class(GREEN => 1)";
  is ''.$described_class->BLUE  => "$described_class(BLUE => 2)";
};

subtest "it can list all of it's members" => sub {
  is_all_members $described_class->all;
  is_all_members $described_class->members;
};

subtest "it can count all of it's members" => sub {
  my $members = $described_class->members;

  is $members => 3;
};

subtest "it can create lists of selected members" => sub {
  my $members = [
    $described_class->RED,
    $described_class->BLUE
  ];

  is_deeply [$described_class->members('RED', 'BLUE')], $members;
  is_deeply scalar($described_class->all('RED', 'BLUE')), $members;
};

subtest "it can create lists of selected values" => sub {
  my $values = [
    $described_class->RED->value,
    $described_class->BLUE->value
  ];

  is_deeply [$described_class->values_of('RED', 'BLUE')], $values;
};

subtest "it can reference all of it's members" => sub {
  my $members = $described_class->all;

  is_all_members @$members
};

subtest 'it can coerce values to the correct subtype' => sub {
  is $described_class->coerce(2) => $described_class->BLUE;
};

subtest 'it can coerce key names to the correct subtype' => sub {
  is $described_class->coerce('BluE') => $described_class->BLUE;
};

subtest 'it can coerce instances to themselves' => sub {
  is $described_class->coerce($described_class->BLUE) => $described_class->BLUE;
};

subtest 'it can validate a value' => sub {
  ok  $described_class->is_value(2);
  ok !$described_class->is_value(10);
};

subtest 'it can validate a key' => sub {
  ok  $described_class->is_key('reD');
  ok !$described_class->is_key('YELLOW');
};

subtest "can create an alias when imported" => sub {
  Mock::Color->import('-alias');

  is Color() => 'Mock::Color';
};

# Auto-mapped string values
$described_class = 'Mock::Shell';
package Mock::Shell {
  use Llama::Enum qw(WEB IOS ANDROID);
}

subtest "it defines a set of subtypes that map the name it's string value" => sub {
  is $described_class->WEB->value     => 'WEB';
  is $described_class->IOS->value     => 'IOS';
  is $described_class->ANDROID->value => 'ANDROID';
};

subtest "the key of an instance is the same as it's value" => sub {
  is $described_class->WEB->key     => $described_class->WEB->value;
  is $described_class->IOS->key     => $described_class->IOS->value;
  is $described_class->ANDROID->key => $described_class->ANDROID->value;
};

# Case-sensitive string values, subclassing & adding members dynamically
$described_class = 'Mock::FolderType';
package Mock::FolderType {
  use Llama::Enum {
    ORG      => 'O',
    PERSONAL => 'P',
    FAMILY   => 'F',
    TRAINING => 'T',
    DEMO     => 'D',
    ARCHIVE  => 'A',
  };

  sub root { shift }
  sub subfolder {
    my $self = shift;
    return $self->parent->of(lc $self->value);
  }

  package Mock::FolderType::Subfolder {
    our @ISA = qw(Mock::FolderType);

    sub new {
      my ($class, $value) = @_;
      $value = lc $value;
      bless \$value, $class;
    }

    sub subfolder { shift }
    sub root {
      my $self = shift;
      return $self->parent->of(uc $self->value);
    }
  }

  Mock::FolderType->add($_->key . "_SUB" => Mock::FolderType::Subfolder->new($_->value)) for Mock::FolderType->members;
}

subtest 'keys will generate properly' => sub {
  is $described_class->ORG->key => 'ORG';
  is $described_class->ORG_SUB->key => 'ORG_SUB';
};

subtest 'string equality will match the key with case-insensive string equality' => sub {
  ok 'ORG' eq $described_class->ORG;
  ok $described_class->ORG eq 'Org';
  ok $described_class->ORG ne 'ORG_SUB';
};

subtest 'string equality will match the value with case-sensitive string equality' => sub {
  ok 'o' eq $described_class->ORG_SUB;
  ok $described_class->ORG eq 'O';
  ok $described_class->ORG ne 'o';
};

subtest 'parent class methods are resolved correctly' => sub {
  is $described_class->ORG => $described_class->ORG->root;
  is $described_class->ORG_SUB => $described_class->ORG->subfolder;
};

subtest 'subclass methods are resolved correctly' => sub {
  is $described_class->ORG_SUB => $described_class->ORG_SUB->subfolder, 'subfolder';
  is $described_class->ORG => $described_class->ORG_SUB->root, 'root';
};

subtest "it will die when adding an instance that isn't a subclass of the enum" => sub {
  my $object = Mock::Color->RED;

  try {
    $described_class->add('HEY', $object);
    fail('did not die');
  } catch ($e) {
    like $e => qr/only subclass instances can be members/;
  }
};

subtest "when a member is added without a value the key given will be it's value" => sub {
  $described_class->add('YOU');

  is $described_class->YOU->value => 'YOU';
};

done_testing;
