package Llama::Pair::Test;
use Llama::Test::TestSuite;
use Feature::Compat::Try;

my $described_class = 'Llama::Record';
require_ok $described_class;

my $class = $described_class->new(
  name       => 'Person',
  attributes => {
    name     => 'Str',
    dob      => 'DateTime',
    email    => 'Str',
    phone    => 'Str',
    metadata => { mutable => 1, optional => 1 }
  }
);

my $jackie = $class->name->new(
  name  => 'Jackie',
  email => 'jackie@example.com',
  phone => '207-555-1234',
  dob   => [1992, 2, 5]
);

is $jackie->name => 'Jackie';
is $jackie->email => 'jackie@example.com';

try {
  $class->name->new(name => 'Joe');
  fail('nothing raised');
} catch ($e) {
  pass("error $e raised");
  like $e => qr/\w+ is required/;
}

done_testing;
