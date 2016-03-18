#!/usr/bin/env perl

# Print the commits that introduce any of the blobs passed in on stdin
# Takes 'git rev-list' style arguments for selecting commits to check which it
# passes through to 'git log'

use strict;
use warnings;

my %blobs;

while (<STDIN>) {
    if (m/^([[:xdigit:]]{40})/) {
        $blobs{$1} = undef;
    }
}

open my $git_cmd, "-|", qw(git log -c --raw --no-abbrev), "--pretty=commit %h", @ARGV
    or die "Failed to run git log";

my $commit;
my $commit_printed;
while (<$git_cmd>) {
    chomp;
    if (/^commit ([[:xdigit:]]{40})$/) {
        $commit = $1;
        $commit_printed = 0;
    }
    if (/^(:[^\t]*)\t(.*)$/) {
        my @details = split(" ", $1);
        if (exists($blobs{$details[-2]})) {
            if (defined($commit) && !$commit_printed) {
                print "$commit\n";
                $commit_printed = 1;
            }
        }
    }
}
