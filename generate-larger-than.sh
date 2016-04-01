#!/bin/sh

# SC2016: Expressions don't expand in single quotes, use double quotes for that.
# shellcheck disable=SC2016
if test $# -eq 2
then
    script='{ if ($(NF - 1) >= '$1' && $(NF - 1) < '$2') { print }}'
else
    script='{ if ($(NF - 1) >= '$1') { print }}'
fi

git cat-file --batch-all-objects --batch-check='%(objectname) %(objectsize) %(objecttype)' --buffer |
    awk '{ if ($3 == "blob") { print $1, $2 }}' |
    "$(dirname "$0")"/fillout-delta.pl |
    awk "$script"

