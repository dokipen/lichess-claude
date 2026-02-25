#!/bin/bash
# List all worktrees across lichess-claude and sub-repos
#
# Usage: ./scripts/list-worktrees.sh
#
# Shows active worktrees in:
# - lichess-claude (root)
# - All sub-repos (lila, lila-ws, chessground, chessops, scalachess)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "Worktrees across all repos"
echo "=========================="
echo ""

# lichess-claude
echo "=== lichess-claude (root) ==="
git worktree list
echo ""

# Sub-repos
for repo in lila lila-ws chessground chessops scalachess; do
  if [ -d "$repo/.git" ] || [ -f "$repo/.git" ]; then
    echo "=== $repo ==="
    git -C "$repo" worktree list
    echo ""
  fi
done
