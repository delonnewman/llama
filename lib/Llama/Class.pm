package Llama::Class;
use strict;
use warnings;
use utf8;
use feature 'signatures';
use feature 'state';

use Llama::Object qw(:base :constructor);
use Llama::Perl::Package;

sub allocate($class, $name = undef) {
  my $object_id = Llama::Object->OBJECT_ID;

  unless ($name) {
    my $id = sprintf("0x%06X", $object_id);
    $name = __PACKAGE__  . '::__ANON__' . $id;
    $class = 'Llama::AnonymousClass';
  }

  my $object = bless { name => $name, _object_id => $object_id }, $class;

  # method resolution
  mro::set_mro($name, 'c3');

  $object->{name} = $name;
  $object->{_package} = Llama::Perl::Package->new($name);

  $object;
}

sub name ($self) {
  $self->{name} //
    Carp::confess "something unexpected happened, should have name";
}

sub mro ($self, @args) {
  if (@args) {
    mro::set_mro($self->name, $args[0]);
    return $self;
  }

  mro::get_mro($self->name);
}

sub is_anon { 0 }

sub object_id ($self) {
  $self->{_object_id} //
    Carp::confess "something unexpected happened, should have object_id";
}

sub package ($self) {
  $self->{_package} //
    Carp::confess "something unexpected happened, should have package";
}

sub parents ($self) { $self->package->ISA }

{
  no strict 'refs';
  no warnings 'once';
  *module = \&package;
}

package Llama::AnonymousClass;
use Llama::Object 'Llama::Class', ':abstract';

sub is_anon { 1 }

1;
