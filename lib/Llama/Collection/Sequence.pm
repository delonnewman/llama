package Llama::Collection::Sequence;
use Llama::Prelude qw(+Collection :signatures);

sub first { die "NotImplementedError: first" }
sub next  { die "NotImplementedError: next" }
sub empty { die "NotImplementedError: empty" }

sub rest ($self) {
  return $self->next // $self->empty;
}

sub is_empty ($self) {
  return $self->length == 0;
}

sub toArrayRef ($self) {
  my @array;
  return \@array if $self->is_empty;

  my $seq = $self;
  while ($seq) {
    push @array => $seq->first;
    $seq = $seq->next;
  }

  return \@array;
}

1;
