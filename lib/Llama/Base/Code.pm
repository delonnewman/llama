package Llama::Base::Code;
use Llama::Prelude qw(+Base +Callable :signatures);

use Carp ();

sub allocate ($class, $sub) {
  my $type = ref $sub;
  Carp::confess "invalid reference type: '$type'" unless $type eq 'CODE';

  bless $sub, $class;
}

sub call ($self, @args) { $self->(@args) }

1;
