#!/usr/bin/env perl

# Takes a list of blobs and additional information on stdin and a file
# containing commits that have introduced the blobs and lists summary
# information for each commit and at which paths the blobs were introduced
# in each commit

use strict;
use warnings;

my %blobs;

while (<STDIN>) {
    if (m/^([[:xdigit:]]{40})\s*(.*)$/) {
        $blobs{$1} = $2;
    }
}

open my $infile, "<", $ARGV[0]
    or die "Failed to read commits";
while (<$infile>) {
    chomp;
    system(qw(git show -s), $_);
    print "\n";
    open my $gitcmd, "-|", qw(git show --pretty= --raw -c --no-abbrev), $_;
    while (<$gitcmd>) {
        chomp;
        my ($details, $path, undef) = split("\t", $_, 3);
        my @details = split(" ", $details);
        if (exists($blobs{$details[-2]})) {
            print "$path $details[-2] $blobs{$details[-2]}\n";
        }
    }
    print "\n";
}
close $infile;
