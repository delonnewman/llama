package Llama::Parser::Result;
use Llama::Union {
  Ok    => { -record => { value => 'Any', rest => 'Any' } },
  Error => { -record => { message => 'Str' } }
};

1;
