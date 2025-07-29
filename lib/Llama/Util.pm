package Llama::Util;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(chomped);

sub chomped :prototype($) ($in) {
  local $_ = $in;
  s/\n$//;
  $_;
}


1;
