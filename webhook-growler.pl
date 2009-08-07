#!/usr/bin/perl
use strict;
use 5.008_001;
use AnyEvent::ReverseHTTP;
use AnyEvent::HTTP;
use Mac::Growl;
use Digest::SHA;
use Encode;
use JSON;
use Path::Class;
use XML::LibXML::Simple;
use XML::Atom::Feed;
use CGI;
use URI;
use URI::QueryParam;

$XML::Atom::ForceUnicode = 1;

our $AppName = "Webhook Growler";
Mac::Growl::RegisterNotifications($AppName, [ 'default' ], [ 'default' ], $AppName);

my($name, $token) = @ARGV;

my %plugins = load_plugins();
my %parser = (
    'json' => \&parse_json,
    'xml'  => \&parse_xml,
    'atom+xml' => \&parse_atom,
    'x-www-form-urlencoded' => \&parse_post,
);

my $guard = AnyEvent::ReverseHTTP->new(
    label => $name,
    token => $token || "-",
    on_request => \&handle_request,
    on_register => sub {
        my $url = shift;
        warn "Available plugins:\n";
        for my $plugin (values %plugins) {
            my $uri = URI->new($url);
            $uri->path($plugin->path);
            warn $uri, "\n";
        }
    },
)->connect;

AnyEvent->condvar->recv;

sub handle_request {
    my $req = shift;

    my($events, $res) = find_event($req);
    use XXX;
    WWW $events;
    if ($events && @$events) {
        for my $event (@$events) {
            notify_event($event);
        }
    } else {
        warn "Received event doesn't have a responder:\n", $req->content;
    }

    return $res || "OK";
}

sub find_event {
    my $req  = shift;

    warn $req->content;
    my $payload;
    my $type = (split '/', $req->content_type)[1];
    my $parser = $parser{$type};
    $payload = $parser->($req->content) if $parser;

    my $plugin = $plugins{$req->uri->path}
        or return;

    return $plugin->handle($payload, $req);
}

sub notify_event {
    my $event = shift;

    my $growl = sub {
        eval {
            Mac::Growl::PostNotification($AppName, 'default', encode_utf8($event->{title}), encode_utf8($event->{body}), 0, 0, shift);
        };
    };

    if ($event->{avatar}) {
        my $cv = avatar_cache($event->{avatar});
        $cv->cb(sub { $growl->($cv->recv || "feed.png") });
    } else {
        $growl->(undef);
    }
}

sub avatar_cache {
    my $uri = shift;

    my $dir = "$ENV{HOME}/.webhook-growler";
    mkdir $dir, 0777 unless -e $dir;

    my $cv = AnyEvent->condvar;

    my $path = "$dir/" . Digest::SHA::sha1_hex("$uri");
    if (-e $path) {
        $cv->send($path);
    } else {
        http_get $uri, sub {
            my($body, $hdr) = @_;
            return $cv->send() unless $hdr->{Status} eq 200 && $hdr->{'content-type'} !~ /html/ && $body;

            open my $fh, ">", $path or die $!;
            print $fh $body;
            close $fh;
            $cv->send($path);
        };
    }

    return $cv;
}

sub parse_json {
    JSON::decode_json($_[0]);
}

sub parse_xml {
    XML::LibXML::Simple->new->XMLin($_[0]);
}

sub parse_atom {
    XML::Atom::Feed->new(\$_[0]);
}

sub parse_post {
    my %vars = CGI->new(shift)->Vars;
    $_ = decode_utf8 $_ for values %vars;
    return \%vars;
}

sub load_plugins {
    my $dir = Path::Class::Dir->new("plugins");
    my %plugins;
    while (my $file = $dir->next) {
        next if !-f $file or $file =~ /\~$/;
        my $class = compile_plugin($file);
        $plugins{$class->path} = $class->new;
    }

    return %plugins;
}

sub compile_plugin {
    my $file = shift;

    my $name = $file->basename;
    $name =~ s/\.\w+$//;
    $name =~ s/[^\w]/_/g;
    my $pkg = "Webhook::Growler::Plugin::$name";

    eval <<CODE or die $@;
package $pkg;
use strict;
use base qw(Webhook::Growler::Plugin);

@{[ $file->slurp ]}

sub name { "$name" }
sub path { "/" . shift->name }

1;
CODE

    return $pkg;
}

package Webhook::Growler::Plugin;

sub new {
    bless {}, shift;
}
