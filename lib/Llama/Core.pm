package Llama::Core;
use Llama::Base qw(:signatures);

use Exporter 'import';
our @EXPORT_OK = qw(chomped uniq slurp spit);

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

sub slurp ($file) {
  open my $fh, '<', $file or die "can't read $file";
  local $/='' unless wantarray;

  <$fh>;
}

sub spit ($file, $content) {
  open my $fh, '>', $file or die "can't write to $file";
  print $fh $content;

  $content;
}

1;
