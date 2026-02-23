---
name: create-pr
description: Create a pull request for the current branch
---

# Create Pull Request

Creates a PR for the current branch after verification checks pass.

## Pre-flight Checks

1. **Verify not on main**:
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
     echo "ERROR: Cannot create PR from main/master branch"
     exit 1
   fi
   ```

2. **Identify the repo** (check the remote):
   ```bash
   REPO=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')
   echo "Creating PR for repo: $REPO"
   ```

3. **Run verification** (adapt for repo type):

   For Scala repos (lila, lila-ws, scalachess):
   ```bash
   sbt compile test
   ```

   For TypeScript repos (chessground, chessops):
   ```bash
   pnpm build && pnpm test
   ```

4. **Check for uncommitted changes**:
   ```bash
   git status
   ```

5. **Check for existing PR**:
   ```bash
   gh pr view $(git branch --show-current) --repo $REPO 2>/dev/null && echo "PR already exists" || echo "No existing PR"
   ```

## Commit and Push

```bash
# Stage all changes
git add -A

# Commit with conventional commit message
git commit -m "<type>: <description>

<optional body>

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push with upstream tracking
git push -u origin HEAD
```

### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or updating tests
- `docs`: Documentation changes
- `chore`: Maintenance tasks

## Create PR

```bash
gh pr create --repo $REPO --title "<type>: <Title>" --body "$(cat <<'EOF'
## Summary
- Change 1
- Change 2

## Test plan
- [ ] Build passes
- [ ] Tests pass
- [ ] Manual testing completed

## Screenshots
(if applicable)
EOF
)"
```

## After PR Creation

1. Report the PR URL to the user
2. Note any CI checks that need to pass
3. Mention if reviewers should be assigned
