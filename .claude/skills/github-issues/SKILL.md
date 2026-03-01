---
name: github-issues
description: Managing GitHub issues with the gh CLI for tracking work across lichess repos
user-invokable: false
---

## Overview

This skill covers GitHub issue management using the `gh` CLI. Issues are used to track bugs, features, and tasks across the lichess multi-repo project.

**Detect repo owner first** (if not already set in this session):
```bash
GITHUB_OWNER=$(gh api user --jq '.login')
```

**Primary Repos** (under `$GITHUB_OWNER`):
- `$GITHUB_OWNER/lila` - Main server
- `$GITHUB_OWNER/chessground` - Board UI
- `$GITHUB_OWNER/chessops` - Chess logic (TS)

## Listing Issues

### View open issues
```bash
gh issue list --repo $GITHUB_OWNER/lila
```

### Filter by label
```bash
gh issue list --repo $GITHUB_OWNER/lila --label "bug"
gh issue list --repo $GITHUB_OWNER/lila --label "enhancement"
```

### Search issues
```bash
gh issue list --repo $GITHUB_OWNER/lila --search "keyword" --state open
```

## Reading Issue Details

```bash
gh issue view 42 --repo $GITHUB_OWNER/lila
gh issue view 42 --repo $GITHUB_OWNER/lila --comments
```

## Creating Issues

### Standard issue format
```bash
gh issue create --repo $GITHUB_OWNER/lila \
  --title "type: Brief descriptive title" \
  --body "$(cat <<'EOF'
## Description
[Clear explanation of the work]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Notes
[Any additional context]
EOF
)"
```

**Title prefixes:**
- `feat:` - New feature or enhancement
- `fix:` - Bug fix
- `refactor:` - Code change without behavior change
- `test:` - Test coverage addition
- `docs:` - Documentation update
- `chore:` - Maintenance tasks

## Updating Issues

### Edit title or body
```bash
gh issue edit 42 --repo $GITHUB_OWNER/lila --title "New title"
```

### Manage labels
```bash
gh issue edit 42 --repo $GITHUB_OWNER/lila --add-label "in-progress"
gh issue edit 42 --repo $GITHUB_OWNER/lila --remove-label "bug"
```

### Close or reopen
```bash
gh issue close 42 --repo $GITHUB_OWNER/lila
gh issue close 42 --repo $GITHUB_OWNER/lila --comment "Fixed in PR #45"
```

## Commenting on Issues

```bash
gh issue comment 42 --repo $GITHUB_OWNER/lila --body "Comment text"
```

### Multiline comments
```bash
gh issue comment 42 --repo $GITHUB_OWNER/lila --body "$(cat <<'EOF'
## Progress Update

- [x] Completed initial research
- [ ] Implementation in progress
- [ ] Testing pending
EOF
)"
```

## Linking Issues to PRs

Use closing keywords in PR descriptions:
- `Fixes #42`
- `Closes #42`
- `Resolves #42`

## Cross-Repo Issues

For work spanning multiple repos, note the related repos in the issue:
```bash
gh issue create --repo $GITHUB_OWNER/lila \
  --title "feat: Add feature X" \
  --body "## Description
This feature requires changes in multiple repos.

**Affected repos:**
- lila (backend logic)
- chessground (UI updates)

## Acceptance Criteria
..."
```
