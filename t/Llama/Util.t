package Llama::Util::Test;
use strict;
use warnings;
use utf8;

use Test::More;
use lib qw(../../lib);

use Llama::Util qw(extract_flags);

subtest 'extract_flags' => sub {
  my @args  = (qw(name age), -to => 'person');
  my %flags = extract_flags \@args;

  is $flags{-to} => 'person';
  is_deeply [qw(name age)], \@args;

  @args  = ('Llama::Object',  ':constructor');
  %flags = extract_flags \@args;

  is $flags{-constructor} => 1;
};

done_testing;
