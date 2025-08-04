package Llama::CodeObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Carp ();

use Llama::Object qw(:base :constructor);

use overload '&{}' => sub{shift->CodeRef};

sub allocate ($class) {
  Carp::confess "can't allocate code objects without parameters use $class->new instead";
}

sub new ($class, $sub) {
  my $type = ref($sub);
  Carp::confess "invalid reference type: '$type'"
    unless $type eq 'CODE';

  bless $sub, $class;
}

sub CodeRef ($self) { $self }

1;
