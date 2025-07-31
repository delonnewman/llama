package Llama::Record;
use strict;
use warnings;
use utf8;
use feature 'signatures';

# package Person;
# use Llama::Record (
#  name  => 'Str',
#  dob   => 'DateTime' # will attempt to load if it's not already
#  email => { type => 'Optional[Str]', validate => sub { shift =~ /@/ }
#  phone => sub { shift =~ /(\d{3}) \d{3}-\d{4}/ }
# );
#
# sub age ($self) {
#   # ...calculate age with $self->dob
# }
#
# Llama::Perl::Package->named('DateTime')->is_loaded
#

1;
