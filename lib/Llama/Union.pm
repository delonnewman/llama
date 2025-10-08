package Llama::Union;
use Llama::Prelude qw(+Base :signatures);

use Data::Printer;
use Llama::Base::Symbol;
use Llama::Class;
use Llama::Class::Sum;
use Llama::Class::Unit;
use Llama::Class::Product;
use Llama::Class::Record;

sub import($class, @args) {
  return unless @args;

  my $name = caller;
  my $not_symbolic = ref $args[0] eq 'HASH';
  my $data = $not_symbolic ? $args[0] : symbolic_members(\@args);

  return make_union($name, $data);
}

sub make_union ($name, $data, %options) {
  my $union = Llama::Class::Sum->named($name);
  $union->superclasses('Llama::Base');

  my %union = expand_members($name, $data)->%*;
  for my $name (keys %union) {
    my $member = $union{$name};
    $union->add_member($member, $name);
    unless ($member->isa('Llama::Class::Sum')) {
      $union->add_method($name, sub ($class, @args) { "${class}::$name"->new(@args) });
    }
  }

  return $union;
}

sub expand_members ($name, $data) {
  my %members;
  for my $symbol (keys %$data) {
    my $options = $data->{$symbol};
    if (defined(my $value = $options->{-unit})) {
      $members{$symbol} = unit_member($name, $symbol, $value);
    }
    if (my $fields = $options->{-record}) {
      $members{$symbol} = record_member($name, $symbol, $fields);
    }
    if ($options->{-symbol}) {
      $members{$symbol} = symbolic_member($name, $symbol);
    }
    if (my $union = $options->{-union}) {
      $members{$symbol} = make_union("$name\::$symbol", $union);
    }
  }
  return \%members;
}

sub symbolic_members ($symbols) {
  my %members = map { $_ => { -symbol => 1 } } @$symbols;
  return \%members;
}

sub symbolic_member ($name, $subtype) {
  my $member_name = $name . '::' . $subtype;

  my $class = Llama::Class->named($member_name);
  $class->superclasses('Llama::Base::Symbol');

  return $class;
}

sub record_member ($name, $subtype, $fields) {
  my $member_name = $name . '::' . $subtype;
  my $class = Llama::Class::Record->new($member_name);
  $class->append_superclasses('Llama::Base::Hash');

  for my $name (keys %$fields) {
    my $type = $fields->{$name};
    $class->add_member($type, $name);
  }

  return $class;
}

sub unit_member ($name, $subtype, $value) {
  my $member_name = $name . '::' . $subtype;
  return Llama::Class::Unit->new($member_name, $value);
}

1;

__END__

package Color {
  use Llama::Union {
    Red   => { -unit => 0 },
    Green => { -unit => 1 },
    Blue  => { -unit => 2 },
  };
}

package Result {
  use Llama::Union {
    Ok    => { -tuple  => ['Any'] },
    Error => { -record => { message => 'Str' } },
  };
}
