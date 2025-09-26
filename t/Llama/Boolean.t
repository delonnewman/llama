package Llama::Class::Test;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Test::More;
use lib qw(../../lib);

use Llama::Boolean;
my $described_class = 'Llama::Boolean';

is $described_class->FALSE->value => 0;
is $described_class->TRUE->value => 1;

is int($described_class->FALSE) => 0;
is int($described_class->TRUE) => 1;

is $described_class->FALSE => 'false';
is $described_class->TRUE => 'true';

ok !$described_class->FALSE;
ok  $described_class->TRUE;

ok !$described_class->TRUE ==  $described_class->FALSE;
ok  $described_class->TRUE == !$described_class->FALSE;

my $false_falsy;
$described_class->FALSE->if_falsy(sub { $false_falsy = 1 });
ok $false_falsy;

my $false_truthy;
$described_class->FALSE->if_truthy(sub { $false_truthy = 1 });
ok !$false_truthy;

my $true_truthy;
$described_class->TRUE->if_truthy(sub { $true_truthy = 1 });
ok $true_truthy;

my $true_falsy;
$described_class->TRUE->if_falsy(sub { $true_falsy = 1 });
ok !$true_falsy;

done_testing;
