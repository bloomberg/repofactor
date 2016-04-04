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
