package Llama::Class::Unit::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Class::Unit';
require_ok $described_class;

subtest 'identity' => sub {
  my $class = $described_class->new(3.14159);
  my $pi1 = $class->new_instance;
  my $pi2 = $class->new_instance;

  ok $$pi1 == $$pi2;
  ok $pi1->identical($pi2);
};

subtest 'base' => sub {
  my $default = $described_class->new(3.14159);
  isa_ok $default->new_instance => 'Llama::Base';

  my $default_named = $described_class->new('PI', 3.14159);
  is $default_named->name => 'PI';
  isa_ok $default_named->new_instance => 'Llama::Base';

  package MyBase { use Llama::Base qw(+Base) }
  my $explicit = $described_class->new('PI', 3.14159, 'MyBase');
  isa_ok $explicit->new_instance => 'MyBase';
};

done_testing;
