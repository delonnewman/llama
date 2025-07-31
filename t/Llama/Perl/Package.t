package Llama::Perl::Package::Test;
use strict;
use warnings;
use utf8;

use Test::More;
use lib qw(../../lib);

use Llama::Perl::Package;

sub throws(&@) {
  my ($block, $error_pattern) = @_;
  eval {
    $block->();
  };
  if ($@) {
    fail("wrong exception thrown: $@") if $error_pattern && $@ !~ $error_pattern;
    pass("exception thrown: $@");
  } else {
    fail('no exception thrown');
  }
}

my $described_class = 'Llama::Perl::Package';

package Mock::Package {
  sub first {  }
}

my $name = 'Mock::Package';
my $package = $described_class->new($name);

is $name, $package->name;

my @name = $package->name;
is_deeply [split('::', $name)], \@name;

is 'Mock/Package.pm' => $package->path_name;

is $package->symbol_table_name => "$name\::";

my %table = $package->symbol_table;
is_deeply { first => *Mock::Package::first }, \%table;

my @syms = $package->symbol_names;
is_deeply [qw(first)], \@syms;

my $syms = $package->symbol_names;
is_deeply [qw(first)], $syms;

my $list_util = $described_class->load('List::Util');

$list_util->alias('reduce' => __PACKAGE__ . '::reduce');
can_ok __PACKAGE__, 'reduce';
throws { $list_util->alias('reduce' => 'fold') } qr/fully qualified/;

my $friendly_package = $described_class->new('Friendly');
$friendly_package->add_symbol('greeting', sub { 'hi' });
is 'hi' => Friendly::greeting();

$friendly_package->add_symbol('GREETINGS', { en_US => 'hi' });
{
  no warnings 'once';
  is 'hi' => $Friendly::GREETINGS{en_US};
}

throws {
  no strict 'refs';
  $friendly_package->add_symbol('salutation', \*Friendly::greeting, 'HASH');
} qr/symbol value is not the correct type/;

done_testing;
