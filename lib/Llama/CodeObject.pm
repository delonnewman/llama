package Llama::CodeObject;
use Llama::Base qw(:base :constructor :signatures);

use Carp ();

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
