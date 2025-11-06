package Llama::Macros;
use Llama::Prelude qw(:signatures);

# Import subs from a package that are intended for use as 'macros' in the package
# since they will cleaned up automatically when the package scope ends

# see https://github.com/aferreira/cpan-Sub-Inject/tree/master
# see https://github.com/moose/namespace-autoclean/blob/38f5ae1ef39cbd878e4d39766ff6412032359b07/lib/namespace/autoclean.pm
# see https://github.com/p5sagit/namespace-clean/blob/d234cda606e7dc374064cf2565febc28c7b4a0c4/lib/namespace/clean.pm#L39
#
# https://metacpan.org/pod/Import::Into

sub import ($class) {
  return unless $class eq __PACKAGE__;
  my $caller = caller;
}

1;
