# Finding the causes of repository bloat

This project contains a bunch of tools to help analyse the largest blobs (by
"on disk" storage) in a repository.

Here is a sample sequence of commands showing typical usage:

- Typically start with a clean clone of the repository that you want
  to analyse. It can be bare. For reasonable performance it should be
  cloned onto "local" disk on a reasonably fast Linux machine.

- Add these tools to your `PATH` or use a full path to each
  script or executable.

- Run these tools from the repository undergoing analysis and cleaning.

- Work out a suitable threshold size by running `generate-larger-than.sh` with
  experimental parameters. 50000 might be a good starting point. The size is
  "average bytes after compression by Git".

- Generate a sorted list of objects with file information

  `generate-larger-than.sh 50000 | sort -k2n | add-file-info.sh >../largeobjs.txt`

- Make a report showing the summary of each commit together with the paths which
  introduce the large objects, their uncompressed size and file information

  `report-on-large-objects.sh ../largeobjs.txt`

# Filtering out large blobs

- Create a temporary work directory and export `RFWORK_DIR` to point to this
directory (defaults to the current directory).

- Again, run all commands from the repository being analysed.

- From the above report, edit down a list of blob ids that can be eliminated.
  Call this `large-objects.txt`.

- Generate a remove script

  ```
  make-remove-blobs.pl large-objects.txt >"$RFWORK_DIR"/remove-blobs.pl
  chmod +x "$RFWORK_DIR"/remove-blobs.pl
  ```

- Optionally edit the remove script to filter out any paths that are not
  required at the same time

- Run the filter branch

  `run-filter-branch.sh`

- Create a new "easy rebase" script for moving work-in-progess branches from the
  old history to the new history

  `make-mtnh.pl >"$RFWORK_DIR"/move-to-new-history`

- Push the rewritten refs and the `rewrite-commit-map` branch to all central
  repositories

- Deploy `move-to-new-history` for users to use
