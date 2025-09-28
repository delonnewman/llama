package Llama::Pair::Test;
use Llama::Test::TestSuite;
use Feature::Compat::Try;
no warnings 'experimental::signatures';

my $described_class = 'Llama::Record';
require_ok $described_class;

my $class = Llama::Record::Class->create(
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

package Address {
  use Llama::Record {
    street_address_1 => 'Str',
    street_address_2 => { optional => 1, value => 'Str' },
    city             => 'Str',
    state            => 'Str',
    postal           => 'Str',
    notes            => { value => 'Str', optional => 1, mutable => 1 },
  };
}

my $address = Address->new(
 street_address_1 => '44 Central Ave',
 city             => 'Albuquerque',
 state            => 'NM',
 postal           => '87101',
);

is $address->street_address_1 => '44 Central Ave';
is $address->street_address_2 => undef;
is $address->city             => 'Albuquerque';
is $address->state            => 'NM';
is $address->postal           => '87101';
is $address->notes            => undef;

done_testing;
