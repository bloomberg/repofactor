#!/bin/sh
if ! test -f "$1"
then
    echo >&2 Must supply a \"large objects\" file as parameter
    exit 1
fi

tmp_file=$(mktemp)

if ! test -f "$tmp_file"
then
    echo >&2 Failed to create temporary file
    exit 1
fi

cut -d' ' -f1 "$1" | "$(dirname "$0")"/find-blob.pl --all >"$tmp_file" &&
"$(dirname "$0")"/show-interesting.pl "$tmp_file" <"$1"

rm "$tmp_file"
