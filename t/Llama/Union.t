package Llama::Union::Test;
use Llama::Test::TestSuite;

use Carp::Always;
use Feature::Compat::Try;

no strict 'refs';
no warnings 'experimental::signatures';

my $described_class = 'Llama::Union';
require_ok $described_class;

sub isa_union ($value, @args) {
  isa_ok $value, $described_class, "$value";
}

sub isa_union_member ($value, $superclass, @args) {
  isa_ok $value, $described_class, "$value";
  isa_ok $value, $superclass, "$value";
}

sub members_are_ok ($member_class, $superclass = undef) {
  for ($member_class->class->members) {
    isa_union_member $_->name => $member_class, $_;
    isa_ok $_->class->name => $superclass if $superclass;
  }
}

package TrafficLight { use Llama::Union qw(Red Yellow Green) }
my $subject = 'TrafficLight';
isa_union $subject;
members_are_ok $subject;

subtest 'accessor methods' => sub {
  isa_union_member $subject->Red => $subject;
  isa_union_member $subject->Yellow => $subject;
  isa_union_member $subject->Green => $subject;

  ok $subject->Red->identical($subject->Red);
  ok $subject->Yellow->identical($subject->Yellow);
  ok $subject->Green->identical($subject->Green);
};

package Color {
  use Llama::Union {
    Red   => { -unit => 0 },
    Green => { -unit => 1 },
    Blue  => { -unit => 2 },
  };
}
$subject = 'Color';
isa_union $subject;
members_are_ok $subject => 'Llama::Class::Unit';

package Result {
  use Llama::Union {
    Ok    => { -record => { value => 'Any' } },
    Error => { -record => { message => 'Str' } },
  };
}
$subject = 'Result';
isa_union $subject;
members_are_ok $subject => 'Llama::Class::Product';

subtest 'record members' => sub {
  ok $_->is_subclass('Llama::Base::Hash'), "$_ subclasses Llama::Base::Hash" for $subject->class->members;

  my $ok = $subject->Ok(value => 1);
  is $ok->value => 1;

  my $error = $subject->Error(message => 'Hey!');
  is $error->message => 'Hey!';
};

package TripleResult {
  use Llama::Union {
    Ok      => { -record => { value => 'Any' } },
    Error   => { -unit   => 'Error!' },
    Nothing => { -symbol => 1 }
  };
}
$subject = 'TripleResult';
isa_union $subject;
members_are_ok $subject;

subtest 'mixed members' => sub {
  isa_ok $subject->Ok(value => 1)->class, 'Llama::Class::Record';
  isa_ok $subject->Error->class, 'Llama::Class::Unit';
  isa_ok $subject->Nothing->class, 'Llama::Class';

  isa_ok $subject->Ok(value => 1), 'Llama::Base::Hash';
  isa_ok $subject->Error, 'Llama::Base';
  isa_ok $subject->Nothing, 'Llama::Base::Symbol';
};

package NestedResult {
  use Llama::Union {
    Error => { -record => { message => 'Str' } },
    Ok    => { -union  => {
      Nothing => { -symbol =>  1 },
      Data    => { -record => { value => 'Any' } },
    } },
  };
}
$subject = 'NestedResult';
isa_union $subject;
members_are_ok $subject;

subtest 'union members' => sub {
  isa_ok $subject->Error(message => 'Doh!')->class, 'Llama::Class::Record';
  isa_ok "$subject\::Ok"->Data(value => 1)->class, 'Llama::Class::Record';
  isa_ok "$subject\::Ok"->Nothing->class, 'Llama::Class';

  isa_ok $subject->Error(message => 'Doh!'), 'Llama::Base';
  isa_ok "$subject\::Ok"->Data(value => 1), 'Llama::Base::Hash';
  isa_ok "$subject\::Ok"->Nothing, 'Llama::Base::Symbol';
};

package Type {
  use Llama::Union {
    Undef => { -symbol => 1 },
    Num   => { -symbol => 1 },
    Str   => { -symbol => 1 },
    Ref   => { -union  => {
      Scalar  => { -symbol => 1 },
      Code    => { -symbol => 1 },
      Hash    => { -symbol => 1 },
      Array   => { -symbol => 1 },
      Blessed => { -symbol => 1 },
    } },
  };
}
$subject = 'Type';
isa_union $subject;
members_are_ok $subject;

Type->Undef;
Type->Num;
Type->Str;
Type::Ref->Scalar;
Type::Ref->Code;
Type::Ref->Hash;
Type::Ref->Array;
Type::Ref->Blessed;

done_testing;
