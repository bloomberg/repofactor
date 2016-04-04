#!/usr/bin/env bash

# SC2016: Expressions don't expand in single quotes, use double quotes for that.
# shellcheck disable=SC2016
index_filter='git ls-files -s |
$RFWORK_DIR/remove-blobs.pl |
git update-index --index-info'

msg_filter='tr \\240 \\040'

# SC2016: Expressions don't expand in single quotes, use double quotes for that.
# shellcheck disable=SC2016
commit_filter='tmp=$(git_commit_non_empty_tree "$@");
[[ $GIT_COMMIT = $tmp ]] || echo >&7 $GIT_COMMIT $tmp;
echo $tmp'

: "${RFWORK_DIR:=$PWD}"
export RFWORK_DIR
git filter-branch\
 --index-filter "$index_filter"\
 --msg-filter "$msg_filter"\
 --commit-filter "$commit_filter"\
 --tag-name-filter cat\
 -- --all\
 7>"$RFWORK_DIR/filter-map.txt" &&
"$(dirname "$0")"/update-commit-map-branch.sh <"$RFWORK_DIR/filter-map.txt"
