package Llama::Value::Type;
use Llama::Prelude qw(:signatures);
use Llama::Union qw(CODE HASH ARRAY SCALAR Regexp GLOB LVALUE FORMAT IO VSTRING SCALAR);

# A set of meta objects for characterizing Perl values--implements type interface.

package Llama::Value::Type::CODE {
  sub parse ($self, $code) {
    my $type = ref $code;
    return $code if $type eq 'CODE';

    die "TypeError: a code reference is expected got $type";
  }
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

package Llama::Value::Type::SCALAR {
  use Llama::Union qw(REF);
  # TODO: add subtypes Num and Str
  
  sub parse ($self, $scalar) { $scalar }
}

package Llama::Value::Type::SCALAR::REF {
  use Llama::Union qw(SCALAR CODE HASH ARRAY Blessed);
  # TODO: add subtype Blessed::Can
}

1;

__END__

Exp::Type
Val::Type (scalar types?)
Var::Type

See https://blogs.perl.org/users/leon_timmermans/2025/02/a-deep-dive-into-the-perl-type-systems.html

See also https://theweeklychallenge.org/blog/unary-operator/
for an example of the need for Perl's other type system Expression Types

See also https://docs.racket-lang.org/reference/contracts.html
for what is probably what we want dynamic checks

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
      - Of(@IN => @OUT)
    - HASH
      - Of($V)
      - Of($K => $V)
    - ARRAY
      - Of($V)
    - Blessed
      - ISA($CLASS)
      - Can(@METHODS)
- CODE
  - Of(@IN => @OUT)
- HASH
  - Of($V)
  - Of($K => $V)
- ARRAY
  - Of($V)
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
