package Llama::Base::Code;
use Llama::Base qw(:base :constructor :signatures);

use Carp ();

use overload '&{}' => sub{shift->CodeRef};

sub allocate ($class, $sub) {
  my $type = ref $sub;
  Carp::confess "invalid reference type: '$type'" unless $type eq 'CODE';

  bless $sub, $class;
}

sub call ($self, @args) { $self->(@args) }

sub CodeRef ($self) { $self }

1;
