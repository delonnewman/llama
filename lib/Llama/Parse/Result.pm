package Llama::Parse::Result;
use Llama::Prelude qw(:signatures);

package Llama::Parse::Result::Ok {
  our @ISA = qw(Llama::Parse::Result);
  use Llama::Record {
    parsed => 'Any',
    rest   => { value => 'Any', optional => 1 }
  };

  sub final ($self) { !$self->rest }
}

package Llama::Parse::Result::Ok {
  use Llama::Record {
    parsed => 'Any',
    rest   => { value => 'Any', optional => 1 }
  };

  sub final ($self) { !$self->rest }
}

1;
