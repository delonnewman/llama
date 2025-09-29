package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);

sub BUILD ($self, @args) {
  if (!@args && (my $required = $self->class->required_attributes)) {
    die "ArgumentError: missing required attribute(s): " . join(', ' => @$required);
  }
  $self->parse(@args);
}

1;
