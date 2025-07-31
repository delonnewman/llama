package Llama::IO;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(slurp spit);

sub slurp :prototype($) ($file) {
  open my $fh, '<', $file or die "can't read $file";
  local $/='' unless wantarray;

  <$fh>;
}

sub spit :prototype($$) ($file, $content) {
  open my $fh, '>', $file or die "can't write to $file";
  print $fh $content;

  $content;
}

1;
