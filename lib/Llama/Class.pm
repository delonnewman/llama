package Llama::Class;
use strict;
use warnings;
use utf8;
use feature 'signatures';
use feature 'state';

use Llama::Object 'Llama::HashObject';
use Llama::Perl::Package;

sub allocate($ref, $name = undef) {
  my $object = $ref->SUPER::allocate(name => $name);

  my $object_id = Llama::Object->OBJECT_ID;
  unless ($name) {
    my $id = sprintf("0x%06X", $object_id);
    $name = __PACKAGE__  . '::__ANON__' . $id;
    {
       no strict 'refs';
       push @{$name . '::ISA'}, 'Llama::AnonymousClass';
    }
  }

  {
    no strict 'refs';
    push @{$name . '::ISA'}, __PACKAGE__;
  }

  my $package = Llama::Perl::Package->new($name);
  $object->{name} = $name;
  $object->{_object_id} = $object_id;
  $object->{_package} = $package;

  $object;
}

sub name ($self) {
  $self->{name} //
    Carp::confess "something unexpected happened, should have name";
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

{
  no strict 'refs';
  no warnings 'once';
  *module = \&package;
}

package Llama::AnonymousClass;

sub is_anon { 1 }

1;
