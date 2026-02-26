package Llama::Attribute::TypeRegistry;
use Llama::Prelude qw(+Base::Hash :signatures);

use Data::Printer;

my $TYPE_PATTERN = qr/
  ^(?<tag>\w+)
  (?:
    \(
      (?<args>\w+(?:\s*,\s*\w+)*)
    \)
  )?
/x;

sub parse ($self, $type) {
  my $form = $self->parse_tag($type);
  my @args = map { $self->parse($_) } @$form[1..$#{$form}];

  unless ($self->has($form->[0]) || @args) {
    return $form->[0];
  }

  return $self->build($form->[0], @args);
}

sub parse_tag ($self, $type) {
  $type =~ $TYPE_PATTERN;
  my $args = $+{args};
  return [$+{tag}] unless $args;
  return [$+{tag}, split /\s*,\s*/ => $args];
}

sub add ($self, $name, $parser) {
  $self->{index} //= {};
  $self->{index}{$name} = $parser;
  return $self;
}

sub has ($self, $name) {
  exists $self->{index}{$name};
}

sub build ($self, $name, @args) {
  my $sub = $self->{index}{$name} // die np($name) . " is not a valid type";
  return $sub->(@args);
}

1;
