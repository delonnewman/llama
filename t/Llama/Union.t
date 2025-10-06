package Llama::Union::Test;
use Llama::Test::TestSuite;

use Feature::Compat::Try;

no strict 'refs';
no warnings 'experimental::signatures';

package Result { use Llama::Union qw(Ok Error) }

my $described_class = 'Llama::Union';
my $subject = 'Result';

sub is_all_members(@actual) {
  my @expected = (
    $subject->Error,
    $subject->Ok,
  );

  @actual = sort { $a->__name__ cmp $b->__name__ } @actual;

  ok $actual[$_]->identical($expected[$_]) for 0..1;
}

subtest 'class hierarchy' => sub {
  isa_ok $subject => $described_class;
  isa_ok $_->name => $subject for $subject->class->members;
};

subtest 'accessor methods' => sub {
  isa_ok $subject->Ok => $subject;
  isa_ok $subject->Error => $subject;

  ok $subject->Ok->identical($subject->Ok);
  ok $subject->Error->identical($subject->Error);
};

subtest "it can list all of it's members" => sub {
  is_all_members $subject->all;
  is_all_members $subject->members;
};

subtest "it can count all of it's members" => sub {
  my $members = $subject->members;
  is $members => 2;
};

subtest "it can create lists of selected members" => sub {
  my $members = [
    $subject->Error,
  ];

  is_deeply [$subject->members('Error')], $members;
  is_deeply scalar($subject->all('Error')), $members;
};

subtest "it can reference all of it's members" => sub {
  my $members = $subject->all;
  is_all_members @$members
};

done_testing;
