#!/bin/bash
# Check for orphaned worktree directories that aren't tracked by git worktree

set -e

WORKTREES_DIR=".worktrees"

if [ ! -d "$WORKTREES_DIR" ]; then
  echo "No $WORKTREES_DIR directory exists yet"
  exit 0
fi

# Get list of tracked worktree paths using porcelain format for reliable parsing
tracked_worktrees=$(git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2-)

found_orphans=0
for dir in "$WORKTREES_DIR"/*/; do
  [ -d "$dir" ] || continue

  # Get absolute path for comparison
  abs_dir=$(cd "$dir" && pwd)

  # Check if this directory is tracked by git worktree
  if ! echo "$tracked_worktrees" | grep -qF "$abs_dir"; then
    echo "Warning: Found orphaned worktree directory: $dir"
    echo "  Run: rm -rf $dir"
    found_orphans=1
  fi
done

if [ $found_orphans -eq 0 ]; then
  echo "Pre-flight check complete: no orphaned worktrees"
  exit 0
else
  echo ""
  echo "Clean up orphaned directories before proceeding"
  exit 1
fi
