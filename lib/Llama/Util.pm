package Llama::Util;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Scalar::Util qw(reftype);

use Exporter 'import';
our @EXPORT_OK = qw(valid_value_type extract_flags);

# see https://github.com/moose/Package-Stash/blob/ac478644bb18a32e2f968138e2d651e47b843423/lib/Package/Stash/PP.pm#L135
sub valid_value_type ($value, $type) {
  return wantarray ? () : undef unless $type;

  my $value_type = reftype($value);
  my $is_valid //= do {
    if ($type eq 'HASH' || $type eq 'ARRAY' || $type eq 'IO'   || $type eq 'CODE') {
      $value_type eq $type;
    } else {
      !defined($value_type) || $value_type eq 'SCALAR' || $value_type eq 'REF' || $value_type eq 'LVALUE' || $value_type eq 'REGEXP' || $value_type eq 'VSTRING';
    }
  };

  wantarray ? ($is_valid, $value_type) : $is_valid;
}

sub extract_flags ($arrayref) {
  my %flags = ();

  for (my $i = 0; $i < @$arrayref; $i++) {
    my $item = $arrayref->[$i];
    if ($item =~ /^-/) {
      delete $arrayref->[$i];
      my $value = delete $arrayref->[$i + 1];
      $flags{$item} = $value;
    }
  }

  wantarray ? %flags : {%flags};
}

1;
