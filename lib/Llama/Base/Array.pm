package Llama::Base::Array;
use Llama::Prelude qw(+Base :signatures);

sub allocate ($self) {
  my $class = ref($self) || $self;
  bless [], $class;
}

sub BUILD ($self, @args) {
  @{$self} = @args;
}

1;
