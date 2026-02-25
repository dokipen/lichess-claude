# Claude Code Rules

## Task Routing

**For implementation work** (features, bugs, refactors, PRs):
1. First invoke `/new-work` if not already in a worktree
2. Then invoke `/lead` to coordinate the phases

**For simple tasks** (questions, explanations, code review without changes):
Respond directly without invoking skills.

## Git Workflow

- The main checkout stays on `main`. All work uses git worktrees via the `/new-work` skill.
- Before pushing to a branch with an open PR, verify with `gh pr view <branch> --repo dokipen/lichess-claude` that it's still open.

### Multi-Repo Coordination

This repo coordinates work across multiple Lichess repositories:

| Repo | Default Branch | Language |
|------|----------------|----------|
| lichess-claude | `main` | Config/Markdown |
| lila | `master` | Scala |
| lila-ws | `master` | Scala |
| chessground | `master` | TypeScript |
| chessops | `main` | TypeScript |
| scalachess | `master` | Scala |

When work spans multiple repos, use the **same branch name** in all repos for traceability.

## GitHub Access

- **Always use `gh` CLI** for all GitHub operations (issues, PRs, comments, reviews, API calls, etc.)
- **Never use WebFetch or URL-fetching tools** for any GitHub URL, including:
  - `https://github.com/dokipen/lichess-claude/...`
  - `https://github.com/lichess-org/...`
  - `https://api.github.com/repos/...`
- Examples: `gh issue view`, `gh pr view`, `gh pr list`, `gh api repos/dokipen/lichess-claude/...`

## Verification

### Scala (lila, lila-ws, scalachess)

After code changes:
```bash
cd lila && sbt compile test
```

### TypeScript (chessground, chessops)

After code changes:
```bash
pnpm build && pnpm test
```

### lichess-claude

Before creating a PR:
```bash
./scripts/pr-preflight.sh
```

## Recommended Local Settings

To avoid permission prompts during the lead workflow, add these to `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(ls *)",
      "Bash(mkdir *)",
      "Bash(git *)",
      "Bash(gh *)",
      "Bash(sbt *)",
      "Bash(pnpm *)",
      "Bash(./scripts/create-worktree.sh *)",
      "Bash(./scripts/check-orphaned-worktrees.sh)",
      "Bash(./scripts/cleanup-worktree.sh *)",
      "Bash(./scripts/pr-preflight.sh)",
      "Skill(new-work)",
      "Skill(new-work:*)",
      "Skill(lead)",
      "Skill(lead:*)"
    ]
  }
}
```

This covers all commands used by skills and agents in the `/lead` workflow.
