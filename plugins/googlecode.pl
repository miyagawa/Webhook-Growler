sub path { "/googlecode" }

sub handle {
    my($self, $post) = @_;

    my @events;
    for my $commit (@{$post->{revisions}}) {
        push @events, {
            title  => "$commit->{author}",
            body   => "$commit->{author} committed r$commit->{revision} to $post->{project_name}: $commit->{message}",
        };
    }

    return \@events;
}
