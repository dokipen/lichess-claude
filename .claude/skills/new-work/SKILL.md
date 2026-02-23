---
name: new-work
description: Create a new branch for feature development in a specific repo
---

# New Work Setup

Creates a branch for feature development in the appropriate lichess repo.

## Usage

```
/new-work <repo> <issue-number>-<branch-name>
```

**Branch names MUST be prefixed with the GitHub issue number.**

Examples:
- `/new-work lila 42-add-tournament-feature`
- `/new-work chessground 15-fix-drag-animation`
- `/new-work chessops 8-add-chess960-support`

## Available Repos

| Repo | Path | Type |
|------|------|------|
| lila | `lila/` | Scala (Play) |
| lila-ws | `lila-ws/` | Scala (WebSocket) |
| chessground | `chessground/` | TypeScript |
| chessops | `chessops/` | TypeScript |
| scalachess | `scalachess/` | Scala |
| lila-openingexplorer | `lila-openingexplorer/` | Scala |

## What It Does

1. **Navigates to repo**: `cd <repo>/`
2. **Fetches latest**: `git fetch origin`
3. **Creates branch**: `<branch-name>` from `origin/master` or `origin/main`
4. **Confirms setup**: Reports branch and repo

## Commands

```bash
REPO="<repo>"
BRANCH_NAME="<branch-name>"

# Navigate to repo
cd $REPO

# Fetch latest
git fetch origin

# Determine default branch
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

# Create and checkout branch
git checkout -b ${BRANCH_NAME} origin/${DEFAULT_BRANCH}

# Verify setup
git branch --show-current
```

## After Setup

1. Confirm the branch was created: `git branch --show-current`
2. Begin work using the `/lead` workflow or direct implementation
3. When done, use `/create-pr` to create a pull request

## Multi-Repo Work

If your work spans multiple repos:
1. Run `/new-work` for each affected repo
2. Use the same issue number prefix for all branches
3. Create PRs in each repo and link them together

Example:
```
/new-work lila 42-add-feature
/new-work chessground 42-add-feature
```

## Notes

- Never work directly on `main`/`master` - always use branches
- Branch names should be lowercase and hyphenated
- Keep branches focused on a single issue
