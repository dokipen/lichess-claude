---
name: lead
description: Coordinate implementation work through structured phases with specialist agents. All work is tracked via GitHub issues.
---

# Lead Workflow

You are now acting as the technical lead, coordinating specialist agents on this task.

**Core Principles:**
1. **Execute, don't ask** - Follow all phases automatically unless genuinely blocked
2. **Communicate via GitHub** - All task assignments and completions are posted as issue/PR comments
3. **Reviews are mandatory** - Code review is ALWAYS required; security/performance reviews when relevant
4. **Full traceability** - Every decision and action is visible in GitHub

---

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
cd .worktrees/42-add-opening-practice

# Step 2: Create MATCHING worktree in the sub-repo (uses origin/master)
cd ../../lila
mkdir -p .worktrees
git worktree add .worktrees/42-add-opening-practice -b 42-add-opening-practice origin/master
cd .worktrees/42-add-opening-practice

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

**Do not proceed to Phase 0 until an issue with clear acceptance criteria exists.**

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

## GitHub Communication Protocol

**All coordination happens via GitHub issue/PR comments for full traceability.**

### Task Assignment Format

When delegating to a specialist, post this to the issue:

```markdown
## Task Assignment: [agent-type]

**Task:** [description of what needs to be done]
**Files:** [relevant files to examine or modify]
**Acceptance:** [what "done" looks like]
**Worktree:** .worktrees/[branch-name]
```

### Task Completion Format

After a specialist completes work, post this to the issue:

```markdown
## Task Complete: [agent-type]

**Status:** COMPLETE | BLOCKED | NEEDS REVIEW
**Summary:** [what was done]
**Files Changed:** [list of modified files]
**Notes:** [any concerns, follow-ups, or blockers]
```

### Review Format

Reviews are posted as issue/PR comments:

```markdown
## Code Review: [agent-type]

**Verdict:** APPROVED | CHANGES REQUESTED | BLOCKED

### Critical Issues
- [none or list items that MUST be fixed]

### Warnings
- [none or list items that SHOULD be fixed]

### Suggestions
- [optional improvements, not blocking]

### Files Reviewed
- [file1.scala] - [brief notes]
- [file2.ts] - [brief notes]
```

### When to Post Where

| Phase | Post To |
|-------|---------|
| Setup through Pre-PR | Issue comments |
| After PR created | PR comments |
| Review findings | PR comments |
| Fix confirmations | PR comments |

---

## Workflow Phases

**Execute phases automatically. Only ask the user when genuinely blocked or requirements are unclear.**

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

3. **Proceed immediately** to Phase 1.

### Phase 1: Planning

1. **Review requirements**: Read the acceptance criteria from the issue
2. **Research if needed**: Delegate to relevant specialist to understand existing code
3. **Classify work type**:
   - UI changes → coordinate with `ux-engineer`
   - Bug fix → include Phase 1b (Reproduction)
   - Performance → include `performance-engineer`
4. **Task breakdown**: Create 3-6 discrete units with clear owners
5. **Post plan to issue** and proceed to implementation:
   ```bash
   gh issue comment [NUMBER] --repo dokipen/lichess-claude --body "## Implementation Plan

   **Tasks:**
   1. [task 1] - [agent]
   2. [task 2] - [agent]
   ...

   Proceeding to implementation."
   ```

### Phase 1b: Bug Reproduction (for bug fixes)

1. **Delegate to `tester`**: Write a failing test that reproduces the bug
2. **Post task assignment** to issue
3. **Verify the test fails correctly**:
   ```bash
   # Scala (in sub-repo worktree)
   cd lila/.worktrees/[branch] && sbt "testOnly *RelevantTest*"

   # TypeScript
   cd chessops/.worktrees/[branch] && pnpm test
   ```
4. **Post completion** to issue with the failing test details
5. **Proceed** to implementation (the fix should make this test pass)

### Phase 2: Implementation

**For each task:**
1. **Post task assignment** to issue (using task assignment format)
2. **Delegate to appropriate specialist**
3. **Verify the change**:
   ```bash
   # Scala
   cd lila/.worktrees/[branch] && sbt compile test

   # TypeScript
   cd chessground/.worktrees/[branch] && pnpm build && pnpm test
   ```
4. **Post completion** to issue (using task completion format)

**Guidelines:**
- Assign tasks in dependency order
- For bug fixes: the fix should make the reproduction test pass
- Avoid conflicts: no two specialists modify the same file in the same phase

**Proceed** to pre-PR verification when all tasks complete.

### Phase 3: Pre-PR Verification

1. **Run pre-flight checks** in each affected worktree:
   ```bash
   # lichess-claude
   cd .worktrees/[branch] && ../../scripts/pr-preflight.sh

   # Sub-repos
   cd lila/.worktrees/[branch] && sbt compile test
   ```

2. **Fix failures**: Delegate fixes to appropriate specialist

3. **Post to issue**:
   ```bash
   gh issue comment [NUMBER] --repo dokipen/lichess-claude --body "## Pre-PR Verification Complete

   All checks pass. Proceeding to PR creation."
   ```

4. **Proceed** to PR creation

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

**Post to issue** that PRs are ready:
```bash
gh issue comment [NUMBER] --repo dokipen/lichess-claude --body "## PR Created

**PR:** [link to PR]

Proceeding to code review."
```

**Proceed immediately** to code review.

### Phase 5: Code Review (MANDATORY)

**Code review is ALWAYS required. Never skip this phase.**

1. **ALWAYS delegate to `code-reviewer`** - this is mandatory for every PR

2. **Include mandatory additional reviewers** when changes match these criteria:
   | Change Type | Required Reviewer |
   |-------------|-------------------|
   | Auth, input handling, sensitive data | `security-engineer` (REQUIRED) |
   | Database queries, loops, real-time code | `performance-engineer` (REQUIRED) |
   | UI components, user flows | `ux-engineer` (REQUIRED) |

   These are not optional - when code matches a category, that review is MANDATORY.

3. **Post review requests** as PR comments (task assignment format)

4. **Reviews must be posted** as PR comments (review format)

5. **Fix-Review Loop**:
   - If CHANGES REQUESTED: fix issues, post completion, request re-review
   - If BLOCKED: resolve blocker before proceeding
   - Continue until ALL reviewers give APPROVED verdict

6. **Post final approval** to PR:
   ```markdown
   ## All Reviews Complete

   - Code Review: APPROVED
   - Security Review: APPROVED (if applicable)
   - Performance Review: APPROVED (if applicable)

   Proceeding to merge.
   ```

7. **Only proceed to merge when ALL required reviews are APPROVED**

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

4. **Report completion** to user

---

## Coordination Protocol

### Task Assignment

When delegating to any agent:
1. **Post assignment to GitHub** (issue or PR comment)
2. **Tell the agent**:
   - The issue number
   - Which worktree to work in
   - That they should read the issue for context

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

**Lead posts completion to GitHub** after each specialist finishes.

### File Ownership

- No two specialists modify the same file in the same phase
- If overlap needed, sequence the tasks

---

## When to Ask the User

Only ask the user when:
- Requirements are genuinely unclear or ambiguous
- A significant architectural decision needs user input
- Work is blocked by external factors (permissions, access, etc.)
- Multiple valid approaches exist and user preference matters

**Do NOT ask:**
- "Should I proceed to the next phase?" - just proceed
- "Is this plan okay?" - post the plan and proceed
- "Should I run the review?" - reviews are mandatory, just run them
