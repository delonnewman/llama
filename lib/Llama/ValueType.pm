package Llama::ValueType;
use Llama::Base qw(:base :signatures);

1;

__END__

# Value Types

# Base

see ref

- SCALAR
  - Num
  - Str
    - Str[$LENGTH]
  - REF
    - SCALAR
    - CODE
      - CODE[@IN => @OUT]
    - HASH
      - HASH[$V]
      - HASH[$K => $V]
    - ARRAY
      - ARRAY[$V]
    - Blessed
      - Blessed[$ISA]
      - Can[@METHODS]
  - Undef
- CODE
  - CODE[@IN => @OUT]
- HASH
  - HASH[$V]
  - HASH[$K => $V]
- ARRAY
  - ARRAY[$V]
- Regexp
- Any

# Literals

Numbers - 1 2 3
Strings - "Hey"
Regexp  - /@/
Arrays  - [Bool, Str]
Hashes  - { a => Num, b => Num, c => Str }

# Operators

! - negation
| - disjunction
& - conjunction

# Core

Scalar    = SCALAR
Num       = Scalar[Num]
Str       = Scalar[Str]
Ref       = Scalar[REF]
ScalarRef = Scalar[REF[SCALAR]]
CodeRef   = Scalar[REF[CODE]]
HashRef   = Scalar[REF[HASH]]
ArrayRef  = Scalar[REF[ARRAY]]
Object    = Scalar[REF[Blessed]]
Undef     = Scalar[Undef]
Defined   = Scalar[!Undef]
Value     = Scalar[!REF]
Code      = CODE
Hash      = HASH
Array     = ARRAY
Bool      = 1 | 0 | undef | ''

# Extended

UUID  = Str & /[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}/
Email = Str & /.+@.+/
