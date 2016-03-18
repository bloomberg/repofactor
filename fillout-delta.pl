#!/usr/bin/env perl

#
# Script to print an "average" size-on-disk for delta compressed objects
# It takes an input format of:
#   <id> [<other fields>...]
# and outputs two extra fields, the average size-on-disk for all objects in the
# same delta chain and the root object of the delta chain:
#   <id> [<other fields>...] <avg size on disk> <root object of delta chain>

use warnings;
use strict;
use FileHandle;
use IPC::Open2;
use POSIX 'ceil';

# We keep a single 'cat-file' process open throught so we can query
# blob-at-a-time efficiently. 'cat-file' is designed for this sort of usage so
# there should be no buffering issues.

my $batch_check = open2(*batch_result, *batch_check,
        "git cat-file --batch-check='%(deltabase) %(objectsize:disk)'");

sub check {
    my ($in) = @_;
    print batch_check "$in\n";
    my $result = <batch_result>;
    chomp $result;
    return split(" ", $result);
}

my %delta_map;

sub add_entry {
    my ($id) = @_;
    my ($next, $size_on_disk) = check($id);
    if (!defined($size_on_disk)) {
        die "oops"
    }
    if (!exists($delta_map{$id})) {
        my $ref;
        if ($next eq "0000000000000000000000000000000000000000") {
            $delta_map{$id} = { base => $id,
                                depth => 0,
                                size_on_disk => $size_on_disk };
        }
        else {
            if (exists($delta_map{$next})) {
                $ref = $delta_map{$next};
            } else {
                $ref = add_entry($next);
            }
            $delta_map{$id} = { base => $ref->{base},
                                depth => $ref->{depth} + 1,
                                size_on_disk => $size_on_disk };
        }
    }
    return $delta_map{$id};
}

my @rows;

while (<STDIN>) {
    chomp;
    my @fields = split(/ /, $_, 2);
    if ($fields[0] =~ /^[[:xdigit:]]{40}$/) {
        my $entry = add_entry($fields[0]);
        push @rows, \@fields;
    }
}

my %base_chains;

for my $id (keys %delta_map) {
    my $ref = $delta_map{$id};
    if (!exists($base_chains{$ref->{base}})) {
        $base_chains{$ref->{base}} = [ 1, 1.0 * $ref->{size_on_disk} ];
    } else {
        my $bcref = $base_chains{$ref->{base}};
        $bcref->[0] += 1;
        $bcref->[1] += ($ref->{size_on_disk} - $bcref->[1]) / $bcref->[0];
    }
}

for (@rows) {
    my $base = $delta_map{$_->[0]}->{base};
    print join(" ", @$_) . " " . ceil($base_chains{$base}->[1]) . " $base\n";
}

close(batch_check);
close(batch_result);
