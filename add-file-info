#!/usr/bin/env bash
#
# Read in a list of sha1 ids with some other information and append the output
# of "file" called on each blob to each line
#
idexpr='^[[:xdigit:]]{40}'
while read -r id rest
do
    fstr=
    if [[ $id =~ $idexpr ]]
    then
        fstr=$(git cat-file blob "$id" | file -)
        fstr=${fstr#/dev/stdin: }
    fi
    printf '%s\n' "$id $rest${fstr+ ${fstr}}"
done
