package Llama::Value::Type;
use Llama::Base qw(:signatures);

# A set of meta objects for characterizing Perl values--implements type interface.

use Llama::Union (
  'CODE',
  'HASH',
  'ARRAY',
  'SCALAR',
  # 'Regexp',
  # 'GLOB',
  # 'LVALUE',
  # 'FORMAT',
  # 'IO',
  # 'VSTRING',
  # {
  #   SCALAR => [
  #     'Num',
  #     'Str',
  #     { REF => ['SCALAR', 'CODE', 'HASH', 'ARRAY', { Blessed => ['Can'] }] }
  #   ]
  # }
);

package Llama::Value::Type::CODE {
  sub parse ($self, $code) {
    my $type = ref $code;
    return $code if $type eq 'CODE';

    die "TypeError: a code reference is expected got $type";
  }
}

package Llama::Value::Type::SCALAR {
  sub parse ($self, $scalar) { $scalar }
}

package Llama::Value::Type::HASH {
  sub parse ($self, @args) {
    die "ArgumentError: expected at least 1 argument got ${\ int @args}" if @args < 1;
    
    if (@args > 1) {
      my %hash = @args;
      return \%hash;
    }

    my $type = ref $args[0];
    die "TypeError: a hash or hash reference is expected got $type" unless $type eq 'HASH';

    return $args[0];
  }
}

package Llama::Value::Type::ARRAY {
  sub parse ($self, @args) {
    die "ArgumentError: expected at least 1 argument got ${\ int @args}" if @args < 1;

    return \@args    if @args > 1;
    return  $args[0] if ref $args[0] eq 'ARRAY';
    return [$args[0]];
  }
}

1;

__END__

sub Any {}
package Llama::ValueType::Any {}

sub SCALAR {}
package Llama::ValueType::SCALAR {
  sub Num {}
  sub Str {}
  sub REF {}
}

package Llama::ValueType::SCALAR::REF {
  sub SCALAR {}
  sub CODE ($IN, $OUT) {}
  sub HASH ($K, $V = undef) {}
  sub ARRAY ($V) {}
  sub Blessed ($ISA) {}
}

package Llama::ValueType::SCALAR::REF::SCALAR {}
package Llama::ValueType::SCALAR::REF::CODE {}
package Llama::ValueType::SCALAR::REF::HASH {}
package Llama::ValueType::SCALAR::REF::ARRAY {}
package Llama::ValueType::SCALAR::REF::Blessed {
  sub Can (@METHODS) {}
}

sub CODE ($IN, $OUT) {}
package Llama::ValueType::CODE {}

sub HASH ($K, $V = undef) {}
package Llama::ValueType::HASH {}

sub ARRAY ($V) {}
package Llama::ValueType::ARRAY {}

sub Regexp {}
package Llama::ValueType::Regexp {}

sub GLOB {}
package Llama::ValueType::GLOB {}

sub LVALUE {}
package Llama::ValueType::LVALUE {}

sub FORMAT {}
package Llama::ValueType::FORMAT {}

sub IO {}
package Llama::ValueType::IO {}

sub VSTRING {}
package Llama::ValueType::VSTRING {}

package Llama::ValueType::Literal {}
package Llama::ValueType::Literal::Number {}
package Llama::ValueType::Literal::String {}
package Llama::ValueType::Literal::Regexp {}
package Llama::ValueType::Literal::Array {}
package Llama::ValueType::Literal::Hash {}

package Llama::ValueType::Operator {}
package Llama::ValueType::Operator::Negation {}
package Llama::ValueType::Operator::Disjunction {}
package Llama::ValueType::Operator::Conjunction {}

# Value Types

# Base

see ref

- Any
- SCALAR
  - Undef
  - Num
  - Str
  - REF
    - SCALAR
    - CODE
      - CODE(@IN => @OUT)
    - HASH
      - HASH($V)
      - HASH($K => $V)
    - ARRAY
      - ARRAY($V)
    - Blessed
      - Blessed($ISA)
      - Can(@METHODS)
- CODE
  - CODE(@IN => @OUT)
- HASH
  - HASH($V)
  - HASH($K => $V)
- ARRAY
  - ARRAY($V)
- Regexp
- GLOB
- LVALUE
- FORMAT
- IO
- VSTRING

# Literals

Numbers - 1 2 3
Strings - 'Hey'
Regexp  - qr/@/
Arrays  - [Bool, Str]
Hashes  - { a => Num, b => Num, c => Str }

# Operators

Not - negation
Or  - disjunction
And - conjunction

# Core

Scalar    = SCALAR
Num       = Scalar::Num
Str       = Scalar::Str
Ref       = Scalar::REF
ScalarRef = Scalar::REF::SCALAR
CodeRef   = Scalar::REF::CODE
HashRef   = Scalar::REF::HASH
ArrayRef  = Scalar::REF::ARRAY
Object    = Scalar::REF::Blessed
Undef     = Scalar::Undef
Defined   = Scalar(Not(Scalar::Undef))
Value     = Scalar(Not(Scalar::REF))
Code      = CODE
Hash      = HASH
Array     = ARRAY
Bool      = Or(1, 0, undef, '')
Maybe($T) = Or(Undef, $T)

# Extended

UUID  = And(Str, qr/[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}/)
Email = And(Str, /.+@.+/)
