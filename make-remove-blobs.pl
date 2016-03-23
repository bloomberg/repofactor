#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);

if (scalar(@ARGV) != 1) {
    die "Must supply list of blobs to remove as input";
}

open my $template, "<", "$Bin/remove-blobs.pl.tmpl" or
    die "Failed to open template file";

while (<$template>) {
    if (m'@@BLOBS_TO_REMOVE@@') {
        open my $infile, "<", $ARGV[0]
            || die "Failed to read blobs to remove $ARGV[0]";
        while (<$infile>) {
            if (/^([[:xdigit:]]{40})/) {
                print("    \"$1\" => undef,\n");
            }
        }
    } else {
        print $_;
    }
}
