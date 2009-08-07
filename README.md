This is Webhook Growler, receives Web hooks over Reverse HTTP and displays Growl notification on your desktop.

Handlers for various webhooks are pluggable, currently supporting PubSubHubbub, Github, Google Code etc. It's so easy to write your own plugin to extra event types.

## INSTALLATION

Webhook Growler requires a couple of CPAN modules. Run the following commands to install them.

    % perl Makefile.PL
    % make installdeps

## CONFIGURATION

The script takes two optional parameters to configure your reversehttp host label and token:

    % ./webhook-growler.pl label token

See http://www.reversehttp.net/ for details.

## COPYRIGHT & LICENSE

Copyright Tatsuhiko Miyagawa 2009-

This software is free software, licensed under the same terms as Perl 5.
