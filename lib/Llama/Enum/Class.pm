package Llama::Enum::Class;

=encoding utf8

=head1 NAME

Llama::Enum::Class

=head2 DESCRIPTION

A meta class for building enum classes (see L<Llama::Enum> and L<Llama::Enum::Member>)

=cut

use Llama::Base qw(+Class :signatures);

use Carp ();
use Data::Printer;
use Sub::Util ();

use Llama::Enum;

no strict 'refs';
no warnings 'experimental::signatures';

sub class ($self) { $self->name }

sub build ($self, $baseclass) {
  my $classname = $self->name;

  # 1) Make enum class inherit from base class i.e. MyEnum->isa('Llama::Enum')
  $self->superclasses($baseclass);

  # 2) Add a method that references the enum parent package i.e. MyEnum->KEY->parent => 'MyEnum'
  $self->add_method(parent => sub { $classname });

  # 3) Override import method in enum class to support aliasing e.g. "use MyEnum -alias => 'My'"
  $self->add_method(import => sub($class, @args) {
    return unless @args && $args[0] eq '-alias';

    my $alias = @args == 1 ? [split '::' => $class]->[-1] : $args[1];
    my ($importer) = caller;

    no strict 'refs';
    *{$importer . '::' . $alias} = sub :prototype() { $class };
  });

  # 4) Ensure that the key and value indexes exist

  $self->add_key_index;
  $self->add_value_index;

  return $self;
}

sub add_key_index ($self) {
  no strict 'refs';
  %{$self->name . '::' . Llama::Enum->KEYS_INDEX} = ();
}

sub add_value_index ($self) {
  no strict 'refs';
  %{$self->name . '::' . Llama::Enum->VALUES_INDEX} = ();
}

1;
