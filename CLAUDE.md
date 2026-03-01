# Claude Code Rules

## Task Routing

**For implementation work** (features, bugs, refactors, PRs):
Invoke `/lead` to coordinate the phases (it handles worktree setup automatically).

**For simple tasks** (questions, explanations, code review without changes):
Respond directly without invoking skills.

## GitHub Owner Detection

This is a multi-repo project where you'll frequently need to reference the user's GitHub fork. **Always detect the GitHub owner dynamically** - never hardcode a username.

At the start of any session that needs GitHub operations, run:
```bash
GITHUB_OWNER=$(gh api user --jq '.login')
```

Then use `$GITHUB_OWNER` in all repo references (e.g., `--repo $GITHUB_OWNER/lichess-claude`).

## Git Workflow

- The main checkout stays on `main`. All work uses git worktrees via the `/new-work` skill.
- Before pushing to a branch with an open PR, verify with `gh pr view <branch> --repo $GITHUB_OWNER/lichess-claude` that it's still open.

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

### Upstream Feature Development

When developing features intended for upstream contribution to lichess-org repositories:

1. **Create feature branches** in all affected repos with the same name (e.g., `opening-practice`)
2. **Issue work branches merge to the feature branch**, not main/master
   - Work branch: `47-add-websocket-handler`
   - PR base: `opening-practice` (not `master`)
3. **When the feature is complete**, create upstream PR from feature branch to lichess-org repo

#### Active Feature Branches

<!-- Add active feature branches here as they are created -->
<!-- Example row: | Feature Name | `branch-name` | lichess-claude, lila | In Development | -->

| Feature | Branch Name | Repos | Status |
|---------|-------------|-------|--------|

**Note**: All issues for an active feature should include a "Branch Strategy" section specifying the target feature branch.

## GitHub Access

- **Always use `gh` CLI** for all GitHub operations (issues, PRs, comments, reviews, API calls, etc.)
- **Never use WebFetch or URL-fetching tools** for any GitHub URL, including:
  - `https://github.com/{user}/lichess-claude/...`
  - `https://github.com/lichess-org/...`
  - `https://api.github.com/repos/...`
- Examples: `gh issue view`, `gh pr view`, `gh pr list`, `gh api repos/$GITHUB_OWNER/lichess-claude/...`

## Agent Teams (Experimental)

This project has the experimental agent teams feature enabled. Agent teams allow coordinating multiple Claude instances working in parallel.

**When to use agent teams:**
- Parallel code reviews (security, performance, tests simultaneously)
- Large features with independent pieces that won't conflict
- Debugging with competing hypotheses

**When to use subagents instead:**
- Simple delegated tasks with a single focus
- Tasks that need to report back to the main conversation

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
