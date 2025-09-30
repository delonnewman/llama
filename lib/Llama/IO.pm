package Llama::IO;
use Llama::Base qw(:signatures);

use Exporter 'import';
our @EXPORT_OK = qw(slurp spit);

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
