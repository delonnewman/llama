package Llama::Delegation;
use Llama::Base qw(:signatures);

use Carp ();

use Llama::Perl::Package;
use Llama::Util qw(extract_flags);

sub import {
  my ($calling_package) = caller;
  my $pkg = Llama::Perl::Package->named($calling_package);

  # delegate qw(os os_version browser browser_version), -to => 'ua', -tx => \&uc;
  # delegate os => 'ua'
  # delegate [qw(os os_version browser browser_version)] => 'ua';
  $pkg->add_sub(delegate => sub (@delegations) {
    for (my $i = 0; $i < @delegations; $i += 2) {
      my ($method, $accessor) = ($delegations[$i], $delegations[$i+1]);
      if (ref $method eq 'ARRAY') {
        for my $meth (@$method) {
          $pkg->add_sub($meth, sub { shift->$accessor()->$meth(@_) });
        }
      } elsif (ref $method eq 'HASH') {
        while (my ($original, $alias) = each %$method) {
          $pkg->add_sub($alias, sub { shift->$accessor()->$original(@_) });
        }
      } else {
        $pkg->add_sub($method, sub { shift->$accessor()->$method(@_) });
      }
    }
    $pkg;
  });
}

1;
