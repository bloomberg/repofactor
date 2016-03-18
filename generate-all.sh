#!/bin/sh
git cat-file --batch-all-objects --batch-check='%(objectname) %(objectsize:disk) %(objectsize) %(objecttype) %(deltabase)' --buffer |
    awk -O '{ if ($4 == "blob") { print $1, $2, $3, $5 }}'
