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

  is $first->ADDR => $second->ADDR;
};

subtest 'eigen classes' => sub {
  package EigenTest {
    use Llama::Object qw(+HashObject :constructor);
  }

  my $object = EigenTest->new;
  isa_ok $object => 'EigenTest';

  my $eigen_class = $described_class->own($object);
  $eigen_class->add_method(translate => sub { 'eigen means own' });

  ok !(EigenTest->new->can('translate'));
  can_ok $object => 'translate';
  isa_ok $object => 'EigenTest';
  isa_ok $eigen_class => 'Llama::Class';
  isa_ok $object => $eigen_class->name;
};

subtest 'attributes' => sub {
  my $class = Llama::Class->new('AttributesTest');
  $class->add_attribute(testing => (mutable => 1));
  $class->set_attribute_value('testing' => 'this is a test');

  no warnings 'once';
  is $class->get_attribute_value('testing') => $AttributesTest::ATTRIBUTE_DATA{testing};

  package ObjectAttributes {
    use Llama::Object qw(+ScalarObject :constructor);
  }
  ObjectAttributes->ADD_ATTRIBUTE(name => (mutable => 1));
  my $object = ObjectAttributes->new;

  my $attribute = ObjectAttributes->OWN_CLASS->attribute('name');
  ok $attribute->is_mutable => 'is mutable';

  my @attributes = $object->ATTRIBUTES;
  is_deeply \@attributes, [qw(name)];

  $attribute = $object->OWN_CLASS->attribute('name');
  ok $attribute->is_mutable => 'is mutable';

  $object->OWN_CLASS->set_attribute_value(name => 'Hosea');
  $object->ADD_METHOD(name => sub ($self) {
    $self->OWN_CLASS->get_attribute_value('name')
  });

  is $object->name => 'Hosea'
};

done_testing;
