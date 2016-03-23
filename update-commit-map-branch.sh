#!/usr/bin/env bash

die () {
	echo >&2 "$*"
	exit 1
}

export GIT_INDEX_FILE
GIT_INDEX_FILE=$(mktemp) ||
    die Failed to create temporary index file

echo "Created temporary index: $GIT_INDEX_FILE"

on_exit () { rm "$GIT_INDEX_FILE"; echo "Removed temporary index: $GIT_INDEX_FILE"; }
trap on_exit EXIT

# TODO - local branch? remote version? for now it's local

if git rev-parse --verify --quiet refs/heads/rewrite-commit-map
then
    old_commit=$(git rev-parse refs/heads/rewrite-commit-map)
fi

# SC2015: Note that A && B || C is not if-then-else. C may run when A is true.
# shellcheck disable=SC2015
git read-tree --empty &&
# read from stdin
blob=$(tac | git hash-object -w --stdin) &&
git update-index --add --cacheinfo 100644,"$blob",commit-map.txt &&
blob=$("$(dirname "$0")/make-mtnh.pl" | git hash-object -w --stdin) &&
git update-index --add --cacheinfo 100755,"$blob",move-to-new-history.sh &&
tree=$(git write-tree) || die Failed to create new tree

if [[ -z $old_commit ]] || [[ $tree != $(git rev-parse "$old_commit^{tree}") ]]
then

    # SC2086: Double quote to prevent globbing and word splitting.
    # shellcheck disable=SC2086
    new_commit=$(git commit-tree -m "Update the commit map"${old_commit:+ -p "$old_commit"} "$tree") ||
        die Failed to create commit

    zero_commit=0000000000000000000000000000000000000000
    git update-ref refs/heads/rewrite-commit-map "$new_commit" "${old_commit:-$zero_commit}"
fi
