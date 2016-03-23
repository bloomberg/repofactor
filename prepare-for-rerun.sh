#!/usr/bin/env bash
# vim: noet tw=80 ts=4 sw=4 syn=sh:

print_ref_updates () {
	for ref in $(git for-each-ref --format='%(refname)' refs/original/)
	do
		refstem=${ref#refs/original/} &&
		pre_rewrite=$(git rev-parse "$ref") &&
		post_rewrite=$(git rev-parse "$refstem") &&
		cat <<-EOF
			update refs/previous-run/$refstem $post_rewrite
			update $refstem $pre_rewrite $post_rewrite
			delete $ref $pre_rewrite
		EOF
	done
}

print_ref_updates | git update-ref --stdin
