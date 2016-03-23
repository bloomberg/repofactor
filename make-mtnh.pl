#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);

sub virtual_roots {
    my @ref_pairs = @{$_[0]};
    my $fwd = $_[1];
    my %roots;
    my %seen_commits;

    while (@ref_pairs) {
        my @slice = splice(@ref_pairs, 0, 375);

        open my $revlist, "-|", qw(git rev-list --reverse --parents),
                                map($_->[1 - $fwd], @slice),
                                "--not",
                                map($_->[$fwd], @slice)
            or return undef;

        OUTER: while (<$revlist>) {
            my ($commit, @parents) = split;
            $seen_commits{$commit} = undef;
            for my $parent (@parents) {
                if (exists($seen_commits{$parent}))
                {
                    next OUTER;
                }
            }
            $roots{$commit} = undef;
        }
    }
    sort keys %roots;
}

sub get_ref_names {
    my @pairs;
    open my $refs, "-|", qw(git for-each-ref --format=%(refname) refs/original/)
        or return undef;
    while (<$refs>) {
        if (m|^refs/original/(.*)|) {
            push @pairs, [ "refs/original/$1", $1 ];
        }
    }
    return @pairs;
}

my @ref_pairs = get_ref_names();

my $old_commits = join " ", virtual_roots(\@ref_pairs, 1);
my $new_commits = join " ", virtual_roots(\@ref_pairs, 0);

my $old_commits_re = qr'@@OLD_HISTORY_COMMITS@@';
my $new_commits_re = qr'@@NEW_HISTORY_COMMITS@@';

open my $template, "<", "$Bin/move-to-new-history.sh.tmpl" or
    die "Failed to open template file";

while (<$template>) {
    s/$old_commits_re/$old_commits/g;
    s/$new_commits_re/$new_commits/g;
    print;
}
