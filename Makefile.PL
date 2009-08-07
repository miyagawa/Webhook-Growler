use inc::Module::Install;
name 'webhook-growler';
all_from 'webhook-growler.pl';

requires 'AnyEvent::ReverseHTTP';
requires 'AnyEvent::HTTP';
requires 'Mac::Growl';
requires 'Digest::SHA';
requires 'Encode';
requires 'JSON';
requires 'Path::Class';
requires 'XML::LibXML::Simple';
requires 'XML::Atom';
requires 'URI';
requires 'URI::QueryParam';

include 'Module::AutoInstall';
auto_install;

install_script 'webhook-growler.pl';
auto_set_repository;
WriteAll;
