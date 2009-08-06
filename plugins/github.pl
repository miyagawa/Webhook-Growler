use Digest::MD5;
sub path { "/github" }

sub handle {
    my($self, $post) = @_;

    my @events;
    for my $commit (@{$post->{commits}}) {
        my $digest = Digest::MD5::md5_hex($commit->{author}{email});
        push @events, {
            avatar => "http://www.gravatar.com/avatar/$digest.jpg",
            title  => "$commit->{author}{name}",
            body   => "$commit->{author}{name} committed to $post->{repository}{name}: $commit->{message}",
        };
    }

    return \@events;
}
