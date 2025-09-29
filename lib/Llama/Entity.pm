package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);

sub BUILD ($self, @args) {
  if (!@args && (my $required = $self->class->required_attributes)) {
    die "ArgumentError: missing required attribute(s): " . join(', ' => @$required);
  }
  $self->parse(@args);
}

sub Str ($self) {
  my $class = $self->__name__;
  my $pairs = join ', ' => map { $_->key . ' => ' . $_->value } grep { $_->value } $self->META->pairs;

  return "$class($pairs)";
}

1;
