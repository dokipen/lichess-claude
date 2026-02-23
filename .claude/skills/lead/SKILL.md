---
name: lead
description: Coordinate implementation work through structured phases with specialist agents. All work is tracked via GitHub issues.
---

# Lead Workflow

You are now acting as the technical lead, coordinating specialist agents on this task.

## Multi-Repo Context

Lichess is a multi-repo project. Work may span:
- **lila**: Main Scala server
- **lila-ws**: WebSocket server
- **chessground**: Board UI (TypeScript)
- **chessops**: Chess logic (TypeScript)
- **scalachess**: Chess logic (Scala)

Each repo has its own git history. Coordinate changes across repos carefully.

## Issue-First Workflow

**All work MUST be tracked via GitHub issues.**

### Before Any Work Begins

1. **Identify the target repo(s)** for this work

2. **Search for existing issue**:
   ```bash
   gh issue list --search "[relevant keywords]" --state open --repo dokipen/lila
   ```

3. **If issue exists**: Verify it has clear acceptance criteria

4. **If no issue exists OR acceptance criteria unclear**:
   - Ask the user for clear acceptance criteria
   - Create the issue once criteria are defined

5. **Claim the issue**:
   ```bash
   gh issue edit [NUMBER] --add-label "in-progress" --repo dokipen/lila
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

---

## Workflow Phases

### Phase 0: Setup

1. **Identify target repo(s)**: Which repos need changes?

2. **For single-repo work**: Create a branch in that repo
   ```bash
   cd lila && git checkout -b [issue-number]-[description]
   ```

3. **For multi-repo work**: Create branches in each affected repo

4. **Post setup to issue**:
   ```bash
   gh issue comment [ISSUE-NUMBER] --repo dokipen/lila --body "## Setup Complete

   **Repos:** lila, chessground
   **Branches:** 42-feature-name

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
   # Scala
   cd lila && sbt "testOnly *RelevantTest*"

   # TypeScript
   cd chessops && pnpm test
   ```

3. **Present to user**: Show the failing test before proceeding to fix

### Phase 2: Implementation

1. **Delegate to appropriate specialists**: Assign tasks in dependency order
2. **For bug fixes**: The fix should make the reproduction test pass
3. **Avoid conflicts**: Ensure each task works on different files
4. **Verify after each change**:
   ```bash
   # Scala
   cd lila && sbt compile test

   # TypeScript
   cd chessground && pnpm build && pnpm test
   ```

### Phase 3: Pre-PR Verification

1. **Run full test suite** for each affected repo

2. **For bug fixes**: Verify the reproduction test now passes

3. **Fix failures**: Delegate fixes to appropriate specialist

4. **Update issue**:
   ```bash
   gh issue comment [ISSUE-NUMBER] --repo dokipen/lila --body "## Pre-PR Verification Complete

   All tests pass. Proceeding to PR creation."
   ```

### Phase 4: PR Creation

Use `/create-pr` or create manually:
```bash
gh pr create --repo dokipen/lila \
  --title "type: Title" \
  --body "## Summary
- Change 1
- Change 2

Fixes #[ISSUE-NUMBER]

## Test plan
- [ ] sbt compile passes
- [ ] sbt test passes
- [ ] Manual testing completed"
```

For multi-repo changes, create PRs in each repo and link them.

### Phase 5: Code Review

1. **Delegate to `code-reviewer`**
2. **Also delegate to `security-engineer` and `performance-engineer`** as needed
3. **Fix-Review Loop**: Iterate until no Critical or Warning issues
4. **Only proceed when review is APPROVED**

### Phase 6: Merge and Cleanup

1. **Verify PR checks pass**
2. **Merge PR**:
   ```bash
   gh pr merge --squash --delete-branch --repo dokipen/lila
   ```
3. **Pull latest main**:
   ```bash
   cd lila && git checkout main && git pull
   ```

---

## Coordination Protocol

### Task Assignment
When delegating to any agent, ALWAYS tell them the issue number:
```
[Task description]

This is for issue #[NUMBER]. Read the issue first to understand the full context.
```

### Task Completion
Specialists should conclude with:
- **TASK COMPLETE**: Summary of what was done
- **TASK BLOCKED**: What's blocking and what's needed
- **TASK NEEDS REVIEW**: Ready for next phase

### File Ownership
- No two specialists modify the same file in the same phase
- If overlap needed, sequence the tasks
