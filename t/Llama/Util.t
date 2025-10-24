package Llama::Util::Test;
use Llama::Test::TestSuite;

use Llama::Util qw(extract_flags extract_block string_hash);

subtest 'extract_block returns a code reference if one is present' => sub {
  my $args = [1, 2, 3, sub { 4 }];
  my $block = extract_block($args);

  is $block->(), 4, 'invoke code reference';
};

subtest 'extract_block removes the code reference from the array when present' => sub {
  my $args = [1, 2, 3, sub { 4 }];
  extract_block($args);

  is_deeply $args, [1, 2, 3], 'block is removed';
};

subtest 'extract_block returns undef if a code reference is not present' => sub {
  my $args = [1, 2, 3, 4];
  my $block = extract_block($args);

  ok !defined($block), 'block is undefined';
};

subtest 'extract_block returns undef if a code reference is present but not at the end of the array' => sub {
  my $args = [1, 2, sub { 3 }, 4];
  my $block = extract_block($args);

  ok !defined($block), 'block is undefined';
};

subtest 'extract_block does not modify the array when a code block is not present' => sub {
  my $args = [1, 2, 3, 4];
  extract_block($args);

  is_deeply $args, [1, 2, 3, 4], 'array is unmodified';
};

subtest 'extract_flags - extracts key / value pairs' => sub {
  my @args  = (qw(name age), -to => 'person');
  my %flags = extract_flags \@args;

  is $flags{-to} => 'person';
  is_deeply [qw(name age)], \@args, 'flags are extracted';
};

subtest 'extract_flags - extracts boolean flags' => sub {
  my @args  = (qw(name age), -to => 'person', ':on');
  my %flags = extract_flags \@args;

  is $flags{-on} => 1;
  is $flags{-to} => 'person';
  is_deeply [qw(name age)], \@args, 'flags are extracted';
};

subtest 'extract_flags - "+" to a prefix value' => sub {
  my @args  = qw(+Object  Llama::Protocol);
  my %flags = extract_flags \@args;

  ok !%flags;
  is_deeply [qw(Llama::Object Llama::Protocol)], \@args;
};

subtest 'regression - undef values in flags' => sub {
  my @args  = (-active => 1, -link => { class => 'text-warning' }, class => 'text-center flex-grow-1', data => { test_id => "person-tab" } => sub { 4 });

  my %flags = extract_flags \@args;
  my @undef = grep { !defined $_ } @args;

  ok !@undef, 'no undefined values';
};

subtest 'string_hash' => sub {
  my $subject = string_hash('/uploads/img_31PXmBA2negA3iU0CwB1h.jpeg');
  my $second  = string_hash('/uploads/img_31PXnjl818sP83E8qHSYn.jpeg');
  my $third   = string_hash('/uploads/img_31PXotG8ITRiAijyDDVHR.jpeg');

  isnt $subject => $second;
  isnt $subject => $third;
  isnt $second  => $third;
};

done_testing;
