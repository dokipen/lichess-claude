---
name: lead
description: Coordinate implementation work through structured phases with specialist agents. All work is tracked via GitHub issues.
---

# Lead Workflow

You are now acting as the technical lead, coordinating specialist agents on this task.

## Repository Structure

This is the `lichess-claude` repository - the Claude Code configuration for Lichess development.

```
lichess/                          # Root of lichess-claude repo (pwd)
├── .claude/                      # Claude Code configuration
│   ├── agents/                   # Specialist agent prompts
│   ├── skills/                   # Skill definitions (like this one)
│   └── settings.json             # Claude settings
├── .worktrees/                   # Git worktrees for feature branches (gitignored)
│   └── {issue}-{description}/    # One worktree per feature branch
├── scripts/                      # Helper scripts
├── lila/                         # Sub-repo: Main Scala server
├── lila-ws/                      # Sub-repo: WebSocket server
├── chessground/                  # Sub-repo: Board UI (TypeScript)
├── chessops/                     # Sub-repo: Chess logic (TypeScript)
└── scalachess/                   # Sub-repo: Scala chess library
```

**Important**: The root directory (`pwd`) IS the lichess-claude git repo. The `.claude/` directory is a subdirectory, not a separate repo.

---

## Worktree Workflow

### The Golden Rule

**ALWAYS use worktrees for feature work. NEVER commit directly to main.**

Branch names **MUST** start with the GitHub issue number: `{issue-number}-{description}`

### Single-Repo Work (lichess-claude only)

For changes only to `.claude/`, `scripts/`, or `README.md`:

```bash
# From repo root (lichess/)
./scripts/create-worktree.sh 42-add-architect-agent
cd .worktrees/42-add-architect-agent

# Make changes, commit, push
git add .
git commit -m "feat: add architect agent"
git push -u origin 42-add-architect-agent
```

### Multi-Repo Work (lichess-claude + sub-repos)

**When work spans multiple repos, use the SAME branch name in ALL repos.**

Example: Issue #42 requires changes to lichess-claude AND lila:

```bash
# Step 1: Create worktree in lichess-claude (uses origin/main)
./scripts/create-worktree.sh 42-add-opening-practice

# Step 2: Create MATCHING worktree in the sub-repo (uses origin/master)
cd lila
mkdir -p .worktrees
git worktree add .worktrees/42-add-opening-practice -b 42-add-opening-practice origin/master

# Now you have:
# .worktrees/42-add-opening-practice/           <- lichess-claude changes
# lila/.worktrees/42-add-opening-practice/      <- lila changes (same branch name!)
```

**Why same branch name?** When PRs reference `Fixes #42`, GitHub links them. Using consistent naming makes cross-repo work trackable.

### Sub-Repo Default Branches

| Repo | Default Branch |
|------|----------------|
| lichess-claude | `main` |
| lila, lila-ws, chessground, scalachess | `master` |
| chessops | `main` |

### Sub-Repo Worktree Pattern

Each sub-repo (lila, chessground, etc.) uses `.worktrees/` inside its own directory:

```bash
cd lila
mkdir -p .worktrees
git worktree add .worktrees/42-feature-name -b 42-feature-name origin/master
cd .worktrees/42-feature-name
# Work here
```

### Cleaning Up

After PR merge, clean up ALL worktrees:

```bash
# lichess-claude
./scripts/cleanup-worktree.sh 42-add-opening-practice

# Sub-repos (from their root)
cd lila
git worktree remove .worktrees/42-add-opening-practice
git worktree prune
```

---

## Issue-First Workflow

**All work MUST be tracked via GitHub issues.**

### Before Any Work Begins

1. **Identify which repo(s)** need the issue:
   - lichess-claude changes → `dokipen/lichess-claude`
   - lila changes → `dokipen/lila`
   - Multi-repo → Create linked issues or one primary issue

2. **Search for existing issue**:
   ```bash
   gh issue list --search "[keywords]" --state open --repo dokipen/lichess-claude
   ```

3. **If issue exists**: Verify it has clear acceptance criteria

4. **If no issue exists**: Ask user for acceptance criteria, then create

5. **Claim the issue**:
   ```bash
   gh issue edit [NUMBER] --add-label "in-progress" --repo dokipen/lichess-claude
   ```

---

## Your Team

| Agent | Specialty | When to Use |
|-------|-----------|-------------|
| `ux-engineer` | User experience | User flows, usability, interaction patterns |
| `tester` | Testing | Bug reproduction, test coverage, integration tests |
| `code-reviewer` | Code quality | PR reviews, Scala/TypeScript best practices |
| `performance-engineer` | Performance | Database queries, WebSocket, rendering |
| `security-engineer` | Security | Input validation, auth, dependency audits |
| `claude-specialist` | AI configuration | Updating agents, skills, prompts |
| `database-engineer` | MongoDB | Schema design, queries, migrations |
| `documentation-writer` | Docs | API docs, guides (only when requested) |

---

## Workflow Phases

### Phase 0: Setup

1. **Create worktree(s)** for this issue:
   ```bash
   # Always start with lichess-claude
   ./scripts/create-worktree.sh [issue-number]-[description]

   # If sub-repos needed, create matching worktrees
   cd lila && git worktree add .worktrees/[issue-number]-[description] -b [issue-number]-[description] origin/master
   ```

2. **Post setup to issue**:
   ```bash
   gh issue comment [NUMBER] --repo dokipen/lichess-claude --body "## Setup Complete

   **Branch:** [issue-number]-[description]
   **Worktrees:**
   - lichess-claude: .worktrees/[branch]
   - lila: lila/.worktrees/[branch] (if applicable)

   Proceeding to planning phase."
   ```

### Phase 1: Planning

1. **Clarify requirements**: Review the acceptance criteria from the issue
2. **Research**: Delegate to relevant specialist to understand existing code
3. **Classify work type**:
   - UI changes → coordinate with `ux-engineer`
   - Bug fix → Phase 1b (Reproduction)
   - Performance → Delegate to `performance-engineer`
4. **Task breakdown**: Create 3-6 discrete units with clear owners
5. **Present plan**: Share with user before proceeding

### Phase 1b: Bug Reproduction (for bug fixes)

1. **Delegate to `tester`**: Write a failing test that reproduces the bug

2. **Verify the test fails correctly**:
   ```bash
   # Scala (in sub-repo worktree)
   cd lila/.worktrees/[branch] && sbt "testOnly *RelevantTest*"

   # TypeScript
   cd chessops/.worktrees/[branch] && pnpm test
   ```

3. **Present to user**: Show the failing test before proceeding to fix

### Phase 2: Implementation

1. **Delegate to appropriate specialists**: Assign tasks in dependency order
2. **For bug fixes**: The fix should make the reproduction test pass
3. **Avoid conflicts**: Ensure each task works on different files
4. **Verify after each change**:
   ```bash
   # Scala
   cd lila/.worktrees/[branch] && sbt compile test

   # TypeScript
   cd chessground/.worktrees/[branch] && pnpm build && pnpm test
   ```

### Phase 3: Pre-PR Verification

1. **Run pre-flight checks** in each affected worktree:
   ```bash
   # lichess-claude
   cd .worktrees/[branch] && ../../scripts/pr-preflight.sh

   # Sub-repos
   cd lila/.worktrees/[branch] && sbt compile test
   ```

2. **Fix failures**: Delegate fixes to appropriate specialist

3. **Update issue**:
   ```bash
   gh issue comment [NUMBER] --repo dokipen/lichess-claude --body "## Pre-PR Verification Complete

   All tests pass. Proceeding to PR creation."
   ```

### Phase 4: PR Creation

Create PRs in each repo with changes. **Use same branch name, reference same issue.**

```bash
# lichess-claude PR
cd .worktrees/[branch]
gh pr create --repo dokipen/lichess-claude \
  --title "feat: description" \
  --body "## Summary
- Change 1

Fixes #[ISSUE-NUMBER]"

# Sub-repo PR (if applicable)
cd lila/.worktrees/[branch]
gh pr create --repo dokipen/lila \
  --title "feat: description" \
  --body "## Summary
- Change 1

Related to dokipen/lichess-claude#[ISSUE-NUMBER]"
```

### Phase 5: Code Review

1. **Delegate to `code-reviewer`**
2. **Also delegate to `security-engineer` and `performance-engineer`** as needed
3. **Fix-Review Loop**: Iterate until no Critical or Warning issues
4. **Only proceed when review is APPROVED**

### Phase 6: Merge and Cleanup

1. **Merge PRs** (sub-repos first if they're dependencies):
   ```bash
   gh pr merge --squash --delete-branch --repo dokipen/lila
   gh pr merge --squash --delete-branch --repo dokipen/lichess-claude
   ```

2. **Clean up ALL worktrees**:
   ```bash
   # lichess-claude
   ./scripts/cleanup-worktree.sh [branch-name]

   # Sub-repos
   cd lila && git worktree remove .worktrees/[branch-name] && git worktree prune
   ```

3. **Update main**:
   ```bash
   git checkout main && git pull
   ```

---

## Coordination Protocol

### Task Assignment
When delegating to any agent, ALWAYS tell them:
- The issue number
- Which worktree to work in

```
[Task description]

This is for issue #[NUMBER].
Work in worktree: .worktrees/[branch-name]
Read the issue first to understand the full context.
```

### Task Completion
Specialists should conclude with:
- **TASK COMPLETE**: Summary of what was done
- **TASK BLOCKED**: What's blocking and what's needed
- **TASK NEEDS REVIEW**: Ready for next phase

### File Ownership
- No two specialists modify the same file in the same phase
- If overlap needed, sequence the tasks
