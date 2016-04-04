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
