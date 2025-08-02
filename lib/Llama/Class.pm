package Llama::Class;
use strict;
use warnings;
use utf8;
use feature 'signatures';
use feature 'state';

no strict 'refs';

use Scalar::Util ();

use Llama::Object qw(:base);
use Llama::Perl::Package;

use constant META_CLASS => '__META_CLASS__';

sub named ($class, $name) {
  my $sym = $name . '::' . META_CLASS;
  my $object = ${$sym};

  unless ($object) {
    $object = $class->new($name);
    ${$sym} = $object;
  }

  $object;
}

sub new ($class, $name = undef) {
  return Llama::AnonymousClass->new unless $name;

  my $object = bless \$name, $class;
  mro::set_mro($name, 'c3');
  $object;
}

sub name ($self) { $$self }

sub mro ($self, @args) {
  if (@args) {
    mro::set_mro($self->name, $args[0]);
    return $self;
  }

  mro::get_mro($self->name);
}

sub package ($self) {
  Llama::Perl::Package->named($self->name)
}

# alias package => 'module';
*module = \&package;

sub superclasses ($self) { $self->package->ISA }
sub subclass ($self, @superclasses) {
  $self->package->ISA(@superclasses);
  $self
}

package Llama::AnonymousClass {
  use Llama::Object 'Llama::Class';

  sub new($class) {
    my $name = '';
    my $object = bless \$name, $class;

    my $address = Scalar::Util::refaddr($object);
    $name .= "$class=OBJECT(" . sprintf("0x%06X", $address) . ')';
    mro::set_mro($name, 'c3');

    $object;
  }
}

package Llama::InstanceClass {
  use Llama::Object 'Llama::Class';

  sub new($class, $object) {
    my $id = sprintf("0x%06X", $object->object_address);
    my $name = "$class=OBJECT($id)";
    push @{$name . '::ISA'}, $class;

    bless $object, $name; # re-bless $self into new class
    return $class->SUPER->new($name);
  }
}

1;
