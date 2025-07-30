package Llama::Core;
use strict;
use warnings;
use utf8;

use Exporter 'import';
our @EXPORT_OK = qw(chomped);

sub chomped :prototype($) {
  local $_ = shift;
  s/\n$//;
  $_;
}

1;
