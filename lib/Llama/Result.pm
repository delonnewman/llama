package Llama::Result;
use Llama::Union {
  Ok    => { -record => { value => 'Any' } },
  Error => { -record => { message => 'Str' } },
  Blank => { -symbol => 1 },
};

1;
