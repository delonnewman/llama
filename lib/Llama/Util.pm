package Llama::Util;

use strict;
use warnings;
use utf8;
use feature ':5.20';
use experimental qw(signatures postderef);

use Data::Printer;
use Scalar::Util qw(reftype);
use POSIX qw(pow);
use Digest::MurmurHash qw(murmur_hash);

use Exporter 'import';

our @EXPORT_OK = qw(
  valid_value_type
  extract_flags
  extract_block
  hash_code
  hash_combine
  string_hash
);

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

=item extract_flags

Remove key / value pairs where the key starts with a '-' and return
a hash reference of those key / value pairs in scalar context. In list
context return a list of the key / value pairs.

  my @args = ('one', 'two', '-three' => 3, ':four');
  my $flags = extract_flags \@args; # => { '-three' => 3, '-four' => 1 };
  @args; # => ('one', 'two')

=cut

sub extract_flags ($arrayref, %options) {
  my $prefix = $options{prefix} // 'Llama';
  my %flags = ();

  for (my $i = 0; $i < @$arrayref; $i++) {
    last unless @$arrayref;
    my $item = $arrayref->[$i];
    if ($item =~ /^-/) {
      $flags{$item} = $arrayref->[$i + 1];
      splice @$arrayref, $i => 2;
      $i -= 2; next;
    }
    if ($item =~ /^:/) {
      $item =~ s/^:/-/;
      $flags{"$item"} = 1;
      splice @$arrayref, $i => 1;
      $i--;
    }
    if ($item =~ /^\+/) {
      my $name = $arrayref->[$i];
      $name =~ s/^\+//;
      $arrayref->[$i] = "$prefix\::$name";
    }
  }

  wantarray ? %flags : \%flags;
}

=item extract_block

Remove and return a code block from the end of the array ref. If a code
block is not present return L<undef>. When the code block is removed the
array is modified in place.

=cut

sub extract_block ($arrayref) {
  return delete $arrayref->[-1] if ref $arrayref->[-1] eq 'CODE';
  return undef;
}

sub string_hash ($string) {
  return 0           unless $string;
  return ord $string if length $string == 1;
  return murmur_hash($string);
}

sub hash_combine ($seed, $hash) {
  $seed ^= $hash + 0x9e3779b9 + ($seed << 6) + ($seed >> 2);
  return $seed;
}

sub hash_code ($val) {
  my $hash;
  if (ref $val eq 'ARRAY') {
    $hash = !$hash ? string_hash($_) : hash_combine($hash, string_hash($_)) for @$val;
  } elsif (ref $val eq 'HASH') {
    $hash = !$hash
      ? hash_combine(string_hash($_), string_hash($val->{$_}))
      : hash_combine($hash, hash_combine(string_hash($_), string_hash($val->{$_}))) for keys %$val;
  } else {
    $hash = string_hash($val);
  }
  return $hash;
}

1;
