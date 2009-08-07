sub handle {
    my($self, $feed, $req) = @_;

    if (my $challenge = $req->uri->query_param('hub.challenge')) {
        # TODO: authorize token
        return [], $challenge;
    }

    # TODO Superfeedr initial handshake

    my @events;
    if ($feed) {
        my $entry = ($feed->entries)[0];

        my($link) = grep { defined && /^https?:/ && !/superfeedr/ } $entry->link->href, $entry->id, $feed->id;
        my $uri = URI->new($link);
        $uri->path_query('/favicon.ico');
        my %event = (
            avatar => $uri,
            title  => $feed->title,
            body   => $entry->title,
        );
        push @events, \%event;
    }

    return \@events;
}
