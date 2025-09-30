package Llama::Core;
use Llama::Base qw(:signatures);

use Exporter 'import';
our @EXPORT_OK = qw(chomped uniq);

sub chomped :prototype($) {
  local $_ = shift;
  s/\n$//;
  $_;
}

sub uniq :prototype(@) {
  my %uniq = map { $_ => $_ } @_;
  my @uniq = values %uniq;
  return wantarray ? @uniq : \@uniq;
}

1;
