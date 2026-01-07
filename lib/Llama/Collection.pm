package Llama::Collection;
use Llama::Prelude ':signatures';

use Llama::Collection::List;

# see https://gitlab.common-lisp.net/fset/fset/-/tree/master?ref_type=heads
# see https://docs.racket-lang.org/collections/index.html
# see https://docs.racket-lang.org/seq/index.html
# see https://docs.racket-lang.org/relation/index.html
# see https://github.com/clojure/clojure

use Exporter 'import';
our @EXPORT_OK = qw(list);

=pod

=head1 Functions

=cut

sub list (@elems) {
  my $list = Llama::Collection::List->empty;

  @elems = reverse @elems;
  $list = $list->cons($_) for @elems;

  return $list;
}

1;
