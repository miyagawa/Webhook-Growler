# TODO key config
sub path { "/hatenabookmark" }

sub handle {
    my($self, $post) = @_;

    my $prefix = substr $post->{username}, 0, 2;
    my %event = (
        avatar => "http://www.hatena.ne.jp/users/$prefix/$post->{username}/profile.gif",
        title  => $post->{username},
    );

    if ($post->{status} eq 'favorite:add' || $post->{status} eq 'add') {
        $event{body} = "$post->{username} bookmarked $post->{title} $post->{url}";
    } elsif ($post->{status} eq 'star') {
        $event{body} = "$post->{username} starred your bookmark $post->{title}";
    } elsif ($post->{status} eq 'id_call') {
        $event{body} = "$post->{username} called you: $post->{comment}";
    } else {
        return;
    }

    return [ \%event ];
}
