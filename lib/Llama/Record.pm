package Llama::Record;
use Llama::Base qw(+Class :constructor :signatures);

1;

__END__

package Person;
use Llama::Record (
 name  => 'Str',
 dob   => 'DateTime', # will attempt to load if it's not already
 email => 'EmailAddress',
 phone => 'PhoneNumber',
);

Llama::AttributeType->add('PhoneNumber', sub { shift =~ /(\d{3}) \d{3}-\d{4}/ });
Llama::AttributeType->add('EmailAddress', sub { shift =~ /@/ });

sub age ($self) {
  # ...calculate age with $self->dob
}

Llama::Perl::Package->named('DateTime')->is_loaded
