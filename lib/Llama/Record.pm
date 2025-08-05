package Llama::Record;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object qw(+HashObject :constructor);

sub ADD_ATTRIBUTE ($self, @args) {
  my $attribute = $self->OWN_CLASS->add_attribute(@args);
  my $name = $attribute->name;
  if ($attribute->is_mutable) {
    $self->add_method($name => sub ($self, @args) {
      Carp::confess "attribute methods only work on instances" unless ref($self);
      if (@args) {
        $self->{$name} = $args[0];
        return $self;
      }
      return $self->{$name};
    });
  } else {
    $self->add_method($name => sub ($self) {
      Carp::confess "attribute methods only work on instances" unless ref($self);
      return $self->{$name};
    });
  }
  $self;
}

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
