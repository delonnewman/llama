package Llama::Class::Test;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Test::More;
use lib qw(../../lib);

use Llama::Class;
my $described_class = 'Llama::Class';

subtest 'basics' => sub {
  my $named = $described_class->new('Basics');
  is $named->name => 'Basics';
  is $named->mro => 'c3';

  my $anon = $described_class->new;
  isa_ok $anon, 'Llama::Class::AnonymousClass';
};

subtest 'caching' => sub {
  my $first = $described_class->named('Testing');
  my $second = $described_class->named('Testing');

  is $first->__addr__ => $second->__addr__;
};

subtest 'eigen classes' => sub {
  package EigenTest {
    use Llama::Base qw(+Base::Hash :constructor);
  }

  my $object = EigenTest->new;
  isa_ok $object => 'EigenTest';

  my $eigen_class = $object->META->eigen_class;
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
  $class->add_attribute(testing => (mutable => 1));
  $class->set_attribute_value('testing' => 'this is a test');

  no warnings 'once';
  is $class->get_attribute_value('testing') => $AttributesTest::ATTRIBUTE_DATA{testing};

  package ObjectAttributes {
    use Llama::Base qw(+Base::Scalar :constructor);
  }
  ObjectAttributes->META->add_attribute(name => (mutable => 1));
  my $object = ObjectAttributes->new(1);

  my $attribute = ObjectAttributes->META->attribute('name');
  ok $attribute->is_mutable => 'is mutable';

  my @attributes = $object->META->attributes;
  is_deeply \@attributes, [qw(name)];

  $attribute = $object->META->eigen_class->attribute('name');
  ok $attribute->is_mutable => 'is mutable';

  $object->META->set_attribute_value(name => 'Hosea');
  $object->META->add_method(name => sub ($self) {
    $self->META->get_attribute_value('name')
  });

  is $object->name => 'Hosea'
};

done_testing;
