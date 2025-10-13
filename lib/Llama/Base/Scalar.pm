package Llama::Base::Scalar;
use Llama::Prelude qw(+Base :signatures);

use Scalar::Util ();

use overload
  '0+' => sub{shift->Num},
  '${}' => sub{shift->ScalarRef};

sub allocate ($class, $value) {
  bless \$value, $class;
}

sub value ($self) { $$self }

sub looks_like_number ($self) {
  Scalar::Util::looks_like_number($self->value)
}

sub toNum ($self) { 0+$self->value }
sub toInt ($self) { int $self->value }
sub toScalarRef ($self) { $self }

1;
