---
name: create-skill
description: This skill should be used when the user wants to create a new Claude Code skill for the lichess project.
version: 1.0.0
disable-model-invocation: true
---

# Create a Lichess Skill

Skills live in `.claude/skills/<name>/SKILL.md`.

## Frontmatter quick reference

```yaml
name: kebab-case-name          # must match directory name
description: "This skill should be used when..."  # triggers auto-invocation
version: 1.0.0
# Pick ONE invocation mode (omit both = Claude + user can invoke):
user-invocable: false          # Claude-only (background knowledge)
disable-model-invocation: true # User-only (/slash-command with side effects)
```

## Invocation mode decision

| Skill type | Flag |
|---|---|
| Background knowledge / conventions | `user-invocable: false` |
| Side-effect workflow (creates files, runs git, etc.) | `disable-model-invocation: true` |
| Both Claude and user should invoke | _(omit both)_ |

## Existing skills in this project

| Skill | Mode | Purpose |
|---|---|---|
| `lead` | User-only | Orchestrate feature work |
| `new-work` | User-only | Create git branches |
| `create-pr` | User-only | Create pull requests |
| `create-skill` | User-only | This skill |
| `github-issues` | Claude-only | GitHub issue management commands |

## Writing the content

- Use imperative/verb-first language ("Create the file" not "You should create")
- Keep SKILL.md under ~100 lines; move large references to `references/` subdirectory
- Include concrete values (constants, commands) — save Claude a file lookup
- No prose padding; every line should earn its place in context

## Lichess-specific considerations

- Remember this is a multi-repo project
- Include repo-specific commands where relevant (sbt vs pnpm)
- Reference the correct GitHub org/repos (dokipen/lila, etc.)

## After creating

Commit the new skill to the .claude repo:
```bash
cd /Users/bob/src/lichess/.claude
git add .
git commit -m "feat: add [skill-name] skill"
git push
```
