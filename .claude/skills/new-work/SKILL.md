---
name: new-work
description: Create a new branch for feature development in a specific repo
---

# New Work Setup

Creates a worktree and branch for feature development.

## Usage

```
/new-work <branch-name>
/new-work <repo> <branch-name>
```

**Branch names MUST be prefixed with the GitHub issue number.**

Examples:
- `/new-work 42-add-architect-agent` - lichess-claude only
- `/new-work lila 42-add-opening-practice` - lila sub-repo

## Repository Structure

```
lichess/                    # Root (lichess-claude repo)
├── .worktrees/             # Worktrees for lichess-claude branches
├── lila/                   # Sub-repo
│   └── .worktrees/         # Worktrees for lila branches
├── chessground/            # Sub-repo
│   └── .worktrees/         # Worktrees for chessground branches
└── ...
```

## Single-Repo Work (lichess-claude)

For changes to `.claude/`, `scripts/`, or docs:

```bash
# From repo root
./scripts/create-worktree.sh 42-add-architect-agent
cd .worktrees/42-add-architect-agent
```

## Sub-Repo Work

For changes to lila, chessground, etc:

```bash
cd <repo>
mkdir -p .worktrees
git worktree add .worktrees/<branch-name> -b <branch-name> origin/master
cd .worktrees/<branch-name>
```

## Multi-Repo Work

**Use the SAME branch name in ALL repos.**

```bash
# Step 1: lichess-claude worktree
./scripts/create-worktree.sh 42-add-opening-practice

# Step 2: lila worktree (same branch name!)
cd lila
mkdir -p .worktrees
git worktree add .worktrees/42-add-opening-practice -b 42-add-opening-practice origin/master
```

## Available Repos

| Repo | Path | Default Branch | Type |
|------|------|----------------|------|
| lichess-claude | `.` | main | Config/Scripts |
| lila | `lila/` | master | Scala (Play) |
| lila-ws | `lila-ws/` | master | Scala (WebSocket) |
| chessground | `chessground/` | master | TypeScript |
| chessops | `chessops/` | main | TypeScript |
| scalachess | `scalachess/` | master | Scala |

## After Setup

1. Confirm the worktree: `git worktree list`
2. Navigate to worktree: `cd .worktrees/<branch-name>`
3. Begin work using `/lead` workflow or direct implementation
4. When done, use `/create-pr` to create a pull request

## Cleanup

After PR merge:

```bash
# lichess-claude
./scripts/cleanup-worktree.sh <branch-name>

# Sub-repos
cd <repo>
git worktree remove .worktrees/<branch-name>
git worktree prune
```

## Notes

- **NEVER** work directly on `main`/`master` - always use worktrees
- Branch names must start with issue number: `42-feature-name`
- Use same branch name across all repos for multi-repo work
- Keep branches focused on a single issue
