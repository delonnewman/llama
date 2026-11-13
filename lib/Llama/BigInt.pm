package Llama::BigInt;
use Llama::Prelude qw(:signatures);

use Carp ();
use Data::Printer;

my $BASE_LEN;

=pod

=head1 METHODS

=head2 new

Given a string representing an integer, returns a reference to an array
of integers, where each integer represents a chunk of the original input
integer.

=cut

sub new ($class, $as_string) {
  my $input_len = length($as_string) - 1;

  Carp::confess "invalid integer value " . np($as_string);
}
