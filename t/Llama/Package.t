package Llama::Package::Test;
use Llama::Test::TestSuite;

use Scalar::Util qw(refaddr);

my $described_class = 'Llama::Package';
require_ok $described_class;

package Mock::Package {
  sub first {  }
}

my $name = 'Mock::Package';
my $package = $described_class->new($name);

subtest "$described_class - named" => sub {
  my $first  = $described_class->named('MetaTest');
  my $second = $described_class->named('MetaTest');

  ok refaddr($first) == refaddr($second);
};

subtest "$described_class - name" => sub {
  is $name, $package->name;

  my @name = $package->name;
  is_deeply [split('::', $name)], \@name;
};

subtest "$described_class - path_name" => sub {
  is 'Mock/Package.pm' => $package->path_name;
};

subtest "$described_class - symbol_table_name" => sub {
  is $package->symbol_table_name => "$name\::";
};

subtest "$described_class - symbol_table" => sub {
  my %table = $package->symbol_table->%*;
  is_deeply { first => *Mock::Package::first }, \%table;
};

subtest "$described_class - symbol_names" => sub {
  my @syms = $package->symbol_names;
  is_deeply [qw(first)], \@syms;

  my $syms = $package->symbol_names;
  is_deeply [qw(first)], $syms;

  my $class_pkg = $described_class->load('Llama::Class');
  doesnt_throw { $syms = $class_pkg->symbol_names('CODE') } # regression
};

subtest "$described_class - alias" => sub {
  my $list_util = $described_class->load('List::Util');

  $list_util->alias('reduce' => __PACKAGE__ . '::reduce');
  can_ok __PACKAGE__, 'reduce';

  throws { $list_util->alias('reduce' => 'fold') } qr/fully qualified/;
};

subtest "$described_class - add_symbol" => sub {
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
};

done_testing;
