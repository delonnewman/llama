package Llama::ScalarObject;
use strict;
use warnings;
use utf8;
use feature 'signatures';

use Llama::Object qw(:base :constructor);

use overload bool => sub{1};

sub allocate ($class, $value) {
  my $object_id = Llama::Object->OBJECT_ID;
  my $id = sprintf("0x%06X", $object_id);
  my $instance_class = "$class=OBJECT($id)";

  {
    no strict 'refs';
    push @{$instance_class . '::ISA'}, $class;
    *{$instance_class . '::object_id'} = sub { $object_id }
  }

  bless \$value, $instance_class;
}

sub value ($self) { $$self }
sub to_int ($self) { int($self->value) }
sub to_string ($self) { ref($self) }

1;
