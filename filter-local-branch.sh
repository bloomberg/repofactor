#!/usr/bin/env bash

die () {
	echo >&2 "$*"
	exit 1
}

get_commit_map_sha () {
	commit_map=
	while read obj
	do
		if [[ -z $commit_map ]]
		then
			commit_map=$obj
		else
			[[ $commit_map = "$obj" ]] ||
				return 1
		fi
	done < <(git show-ref --hash rewrite-commit-map)
	[[ -n "$commit_map" ]] ||
		return 1
	echo "$commit_map"
}

# If there's no rewrite-commit-map branch, then there's nothing to do
commit_map_sha=$(get_commit_map_sha) ||
    die "Failed to find commit map branch"

# SC2015: Note that A && B || C is not if-then-else. C may run when A is true.
# shellcheck disable=SC2015
COMMIT_MAP_DIR=$(mktemp -d) && [[ -d $COMMIT_MAP_DIR ]] ||
    die "Failed to create temporary map directory"

on_exit () { [[ -n $COMMIT_MAP_DIR && -d $COMMIT_MAP_DIR ]] && rm -rf "$COMMIT_MAP_DIR"; }
trap on_exit EXIT

export COMMIT_MAP_DIR

prime_new_filter_map () {
    while read old new
    do
        echo "$new" >"$COMMIT_MAP_DIR/$old"
    done < <(git show "$commit_map_sha":commit-map.txt)
}

prime_new_filter_map

map_commit () {
    [[ -r "$COMMIT_MAP_DIR/$1" ]] &&
		cat "$COMMIT_MAP_DIR/$1"
}

while read -r merge_base
do
	map_commit "$merge_base" && break
done < <(git rev-list HEAD)

[[ -n $merge_base ]] ||
	die "Failed to determine a mappable merge-base"

index_filter="git ls-files -s |
$(readlink -f "$(dirname "$0")")/remove-blobs.pl |
git update-index --index-info"

# SC2016: Expressions don't expand in single quotes, use double quotes for that.
# shellcheck disable=SC2016
parent_filter='out=
read parent_line
for word in $parent_line
do
    if [[ -r "$COMMIT_MAP_DIR/$word" ]]
    then
		out=${out+${out} }$(<"$COMMIT_MAP_DIR/$word")
    else
		out=${out+${out} }$word
    fi
done
echo $out'

git filter-branch -f\
 --index-filter "$index_filter"\
 --parent-filter "$parent_filter"\
 -- HEAD ^"$merge_base"
