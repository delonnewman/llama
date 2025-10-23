package Llama::Class::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Class';
require_ok $described_class;

subtest 'basics' => sub {
  my $named = $described_class->new('Basics');
  isa_ok $named => $described_class;
  is $named->name => 'Basics';
  is $named->mro => 'c3';

  my $anon = $described_class->new;
  isa_ok $anon => $described_class;
  like $anon->name => qr/$described_class=OBJECT/;
  is $named->mro => 'c3';

  my $anon2 = $described_class->new;
  isnt $anon->name => $anon2->name;
};

subtest 'caching' => sub {
  my $first = $described_class->named('Testing');
  my $second = $described_class->named('Testing');

  is $first->__addr__ => $second->__addr__;
};

subtest 'kinds' => sub {
  my $class = $described_class->new;
  $class->append_superclasses('Llama::Base');
  my $instance = bless {}, $class->name;

  is $class->kind => $described_class;
  isa_ok $instance => $class->name;
  isa_ok $instance->class => $described_class;

  my $kind = $described_class->new;
  $kind->append_superclasses('Llama::Class');
  $class->kind($kind->name);
  my $class2 = $described_class->new($class->name);
  my $class3 = $described_class->named($class->name);
  my $instance2 = bless {}, $class2->name;

  isa_ok $class2 => $kind->name;
  isa_ok $class3 => $kind->name;
  is $class->kind => $kind->name;
  isa_ok $instance2->class => $kind->name;
  isa_ok $instance->class => $kind->name;
};

subtest 'eigen classes' => sub {
  package EigenTest {
    use Llama::Prelude qw(+Base :signatures);
    sub new ($class, @args) {
      bless {}, $class;
    }
  }

  my $object = EigenTest->new;
  isa_ok $object => 'EigenTest';

  my $eigen_class = $object->META->eigen_class;
  isa_ok $eigen_class => 'Llama::Class::EigenClass';
  $eigen_class->add_method(translate => sub { 'eigen means own' });

  ok !(EigenTest->new->can('translate'));
  can_ok $object => 'translate';
  isa_ok $object => 'EigenTest';
  isa_ok $eigen_class => 'Llama::Class';
  isa_ok $object => $eigen_class->name;

  ok $object->META->eigen_class->identical($object->META->eigen_class) => 'same instance';
};

subtest 'attributes' => sub {
  my $class = Llama::Class->new('AttributesTest');
  $class->add_attribute(testing => { mutable => 1 });
  $class->set_attribute_value('testing' => 'this is a test');

  no warnings 'once';
  is $class->get_attribute_value('testing') => $AttributesTest::ATTRIBUTE_DATA{testing};

  package ObjectAttributes {
    use Llama::Prelude qw(+Base::Scalar);
  }
  ObjectAttributes->META->add_attribute(name => { mutable => 1 });
  my $object = ObjectAttributes->new(1);

  my $attribute = ObjectAttributes->META->attribute('name');
  ok $attribute->is_mutable => 'is mutable';

  my @attributes = $object->META->attributes;
  is_deeply \@attributes, [qw(name)];

  $attribute = $object->META->eigen_class->attribute('name');
  ok $attribute->is_mutable => 'is mutable';

  $object->META->set_attribute_value(name => 'Hosea');
  $object->META->add_method(name => sub {
    shift->META->get_attribute_value('name')
  });

  is $object->name => 'Hosea'
};

done_testing;
