package Llama::Entity;
use Llama::Base qw(+Base::Hash :signatures);
use Llama::Attributes;

has 'id' => { default => '__id__' };

sub BUILD ($self, @args) {
  if (!@args && (my $required = $self->class->required_attributes)) {
    die "ArgumentError: missing required attribute(s): " . join(', ' => @$required);
  }
  $self->parse(@args);
}

sub equals ($self, $other) {
  return !!0 unless $other->isa(__PACKAGE__);
  return $self->id eq $other->id;
}

1;
