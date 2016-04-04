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

#   Copyright (C) 2015,2016 Bloomberg Finance L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
