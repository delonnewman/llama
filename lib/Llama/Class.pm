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

sub for_instance ($class, $object) {
  Llama::InstanceClass->new($object);
}

my sub cached_instance ($name) {
  my $sym = $name . '::' . META_CLASS;
  ${$sym};
}

my sub cache_instance ($name, $instance) {
  my $sym = $name . '::' . META_CLASS;
  ${$sym} = $instance;
  $instance;
}

sub named ($class, $name) {
  my $object = cached_instance($name);
  $object //= cache_instance($name, $class->new($name));
  $object;
}

sub new ($class, $name = undef) {
  return Llama::AnonymousClass->new unless $name;

  my $object = bless \$name, $class;
  mro::set_mro($name, 'c3');
  $object;
}

sub name ($self) { $$self }

sub version ($self) { $self->package->VERSION }

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

sub add_method ($name, $sub) {
  $self->package->add_symbol($name, $sub, 'CODE');
  $self;
}

package Llama::AnonymousClass {
  use Llama::Object 'Llama::Class';

  sub new($class) {
    my $name = '';
    my $object = bless \$name, $class;

    my $address = Scalar::Util::refaddr($object);
    $name .= "$class=OBJECT(" . sprintf("0x%06X", $address) . ')';
    mro::set_mro($name, 'c3');
    cache_instance($name, $object);

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
    return cache_instance($name, $class->SUPER::new($name));
  }
}

1;
