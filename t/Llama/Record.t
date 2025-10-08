package Llama::Record::Test;
use Llama::Test::TestSuite;
use Feature::Compat::Try;
no warnings 'experimental::signatures';

my $described_class = 'Llama::Record';
require_ok $described_class;

sub isa_record_instance ($instance, $class) {
  isa_ok $instance => $class;
  isa_ok $instance => $described_class;
}

my $class = $described_class->new_class(
  name       => 'Person',
  attributes => {
    name     => 'Str',
    dob      => 'DateTime',
    email    => 'Str',
    phone    => 'Str',
    metadata => { mutable => 1, optional => 1 }
  }
);

isa_ok $class => 'Llama::Class::Record';
isa_ok $class->name => $described_class;

my $jackie = $class->name->new(
  name  => 'Jackie',
  email => 'jackie@example.com',
  phone => '207-555-1234',
  dob   => [1992, 2, 5]
);

isa_record_instance $jackie => $class->name;
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
my $subject = 'Address';
isa_ok $subject => $described_class;

my $address = $subject->new(
 street_address_1 => '44 Central Ave',
 city             => 'Albuquerque',
 state            => 'NM',
 postal           => '87101',
);
isa_record_instance $address => $subject;

is $address->street_address_1 => '44 Central Ave';
is $address->street_address_2 => undef;
is $address->city             => 'Albuquerque';
is $address->state            => 'NM';
is $address->postal           => '87101';
is $address->notes            => undef;

package Entity {
  use Llama::Record {
    name => 'Str',
    type => { default => '__name__' }
  };
}
$subject = 'Entity';

my $entity = $subject->new(name => 'test');
isa_record_instance $entity => $subject;

is $entity->name => 'test';
is $entity->type => $subject;

package Contact {
  use Llama::Prelude qw(+Record);
  use Llama::Attributes;

  has 'name';
  has 'email';
}
$subject = 'Contact';

my $contact = $subject->new(name => 'Paul', email => 'paul@example.com');
isa_record_instance $contact => $subject;

is $contact->name => 'Paul';
is $contact->email => 'paul@example.com';

done_testing;
