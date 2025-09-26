package Llama::Pair::Test;
use Llama::Test::TestSuite;

my $described_class = 'Llama::Record';
require_ok $described_class;

my $class = $described_class->new(
  name       => 'Person',
  attributes => {
    name     => 'Str',
    dob      => 'DateTime',
    email    => 'Str',
    phone    => 'Str',
    metadata => { mutable => 1 }
  }
);

my $jackie = $class->name->new(
  name  => 'Jackie',
  email => 'jackie@example.com',
  dob   => [1992, 2, 5]
);

is $jackie->name => 'Jackie';
is $jackie->email => 'jackie@example.com';

done_testing;
