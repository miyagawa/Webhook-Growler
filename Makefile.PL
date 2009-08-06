use inc::Module::Install;
name 'webhook-growler';
all_from 'webhook-growler.pl';

requires 'AnyEvent::ReverseHTTP';
requires 'Mac::Growl';

install_script 'webhook-growler.pl';
auto_set_repository;
WriteAll;
