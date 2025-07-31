package Llama::Package::Test;
use strict;
use warnings;
use utf8;

use Test::More;
use lib qw(../../lib);

use Llama::Package;

my $described_class = 'Llama::Package';

package Mock::Package {
  sub first {  }
}

my $name = 'Mock::Package';
my $package = $described_class->new($name);

is $name, $package->name;

my @name = $package->name;
is_deeply [split('::', $name)], \@name;

is $package->symbol_table_name => "$name\::";

my %table = $package->symbol_table;
is_deeply { first => *Mock::Package::first }, \%table;

my @subs = $package->subroutine_names;
is_deeply [qw(first)], \@subs;

my $list_util = Llama::Package->load('List::Util');

$list_util->alias('reduce' => 'Llama::Package::Test::reduce');
can_ok __PACKAGE__, 'reduce';

eval {
  $list_util->alias('reduce' => 'fold');
};
if ($@) {
  fail("wrong exception thrown: $@") unless $@ =~ /fully qualified/;
  pass("exception thrown: $@");
} else {
  fail('no exception thrown');
}

done_testing;
