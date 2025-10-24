requires 'Data::Printer';
requires 'Feature::Compat::Try';

requires 'Role::Tiny';
requires 'Type::Tiny';

on 'develop' => sub {
  requires 'Reply';
  requires 'Proc::InvokeEditor';
  requires 'Term::ReadLine::Gnu';
  requires 'Term::ReadKey';
  requires 'B::Keywords';

  requires 'Carp::Always';
};
