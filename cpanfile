requires 'Data::Printer';
requires 'Feature::Compat::Try';

on 'develop' => sub {
  requires 'Reply';
  requires 'Proc::InvokeEditor';
  requires 'Term::ReadLine::Gnu';
  requires 'Term::ReadKey';
  requires 'IO::Pager';
  requires 'B::Keywords';
};
