package Llama::Union::Class;
use Llama::Base qw(+Class :signatures);

use Llama::Union;

no strict 'refs';
no warnings 'experimental::signatures';

sub build ($self, $baseclass) {
  my $classname = $self->name;

  # 1) Make enum class inherit from base class i.e. MyUnion->isa('Llama::Union')
  $self->superclasses($baseclass);

  # 2) Add a method that references the enum parent package i.e. MyUnion->KEY->parent => 'MyEnum'
  $self->add_method(parent => sub { $classname });

  # 3) Override import method in enum class to support aliasing e.g. "use MyUnion -alias => 'My'"
  $self->add_method(import => sub($class, @args) {
    return unless @args && $args[0] eq '-alias';

    my $alias = @args == 1 ? [split '::' => $class]->[-1] : $args[1];
    my ($importer) = caller;

    no strict 'refs';
    *{$importer . '::' . $alias} = sub :prototype() { $class };
  });

  # 4) Ensure that the key and value indexes exist
  %{$self->name . '::MEMBERS'} = ();

  return $self;
}

1;
