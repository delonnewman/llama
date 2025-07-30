package Llama::IO;
use strict;
use warnings;
use utf8;

use Exporter 'import';
our @EXPORT_OK = qw(slurp spit);

sub slurp :prototype($) {
  my $file = shift;

  open my $fh, '<', $file or die "can't read $file";
  local $/='' unless wantarray;

  <$fh>;
}

sub spit :prototype($$) {
  my $file = shift;
  my $content = shift;

  open my $fh, '>', $file or die "can't write to $file";
  print $fh $content;

  $content;
}

1;
