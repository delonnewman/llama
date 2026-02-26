package Llama::Class::EigenClass;
use Llama::Prelude qw(+Class :signatures);
no strict 'refs';

sub build($class, $mirror) {
  my $new_class  = $class->new;
  my $orig_class = $mirror->class;
  my $name       = $orig_class->name;

  # make original class a super class
  $new_class->progenitor($orig_class->name);

  # bless object into new class
  $mirror->BLESS($new_class->name);

  return $new_class;
}

sub progenitor ($self, @args) {
  if (@args) {
    $self->superclasses($args[0]);
    ${$self->package->qualify('ATTRIBUTE_DATA')}{__progenitor__} = $args[0];
    return $self;
  }

  return ${$self->package->qualify('ATTRIBUTE_DATA')}{__progenitor__};
}

1;
