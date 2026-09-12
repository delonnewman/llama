package Llama::Base::Code;
use Llama::Prelude qw(+Base +Callable :signatures);

use Carp ();
use Sub::Util ();

sub new ($class, $sub) {
  my $type = ref $sub;
  Carp::confess "invalid reference type: '$type'" unless $type eq 'CODE';

  bless $sub, $class;
}

sub call ($self, @args) { $self->(@args) }

sub name ($self) { Sub::Util::subname($self) }

sub set_name ($self, $name) {
  Sub::Util::set_subname($name => $self);

  $self;
}

sub toStr ($self) {
  my $name = $self->name;
  my $id   = sprintf("0x%06X", $self->__id__);

  return "$name=OBJECT($id)";
}

sub toCodeRef ($self) { $self }

1;
