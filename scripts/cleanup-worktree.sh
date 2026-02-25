#!/bin/bash
# Clean up a worktree and its remote branch after PR merge
#
# Usage: ./scripts/cleanup-worktree.sh <branch-name>
#
# This script:
# 1. Deletes the remote branch (if it still exists)
# 2. Removes the local worktree directory
# 3. Prunes orphaned worktree references
# 4. Deletes the local branch

set -e

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: ./scripts/cleanup-worktree.sh <branch-name>"
  echo "Example: ./scripts/cleanup-worktree.sh 42-add-feature"
  exit 0
fi

BRANCH_NAME="$1"
WORKTREE_DIR=".worktrees/${BRANCH_NAME}"

echo "Cleaning up worktree: ${BRANCH_NAME}"
echo "=================================="

# Step 1: Delete remote branch (may already be deleted by PR merge)
echo "Deleting remote branch..."
if git push origin --delete "${BRANCH_NAME}" 2>&1; then
  echo "  Remote branch deleted"
else
  # Check if it's just a "not found" error vs a real failure
  if git ls-remote --exit-code --heads origin "${BRANCH_NAME}" >/dev/null 2>&1; then
    echo "  Warning: Failed to delete remote branch (may be a network or permission issue)" >&2
    echo "  You may need to delete it manually: git push origin --delete ${BRANCH_NAME}" >&2
  else
    echo "  Remote branch already deleted or doesn't exist"
  fi
fi

# Step 2: Remove worktree directory
echo "Removing worktree directory..."
if [ -d "${WORKTREE_DIR}" ]; then
  if git worktree remove "${WORKTREE_DIR}" 2>/dev/null; then
    echo "  Worktree removed: ${WORKTREE_DIR}"
  elif git worktree remove --force "${WORKTREE_DIR}" 2>/dev/null; then
    echo "  Worktree force-removed: ${WORKTREE_DIR}"
  else
    echo "  Warning: git worktree remove failed, using rm -rf" >&2
    rm -rf "${WORKTREE_DIR}"
    echo "  Directory removed manually: ${WORKTREE_DIR}"
    echo "  Running git worktree prune to sync git state..."
    git worktree prune
  fi
else
  echo "  Worktree directory not found: ${WORKTREE_DIR}"
fi

# Step 3: Prune orphaned references
echo "Pruning orphaned worktree references..."
git worktree prune
echo "  Pruned"

# Step 4: Delete local branch (force delete since we're explicitly cleaning up)
echo "Deleting local branch..."
git branch -D "${BRANCH_NAME}" 2>/dev/null && echo "  Local branch deleted" || echo "  Local branch already deleted or doesn't exist"

echo ""
echo "Done! Worktree ${BRANCH_NAME} cleaned up."
