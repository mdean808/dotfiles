---
name: qa-steps
description: Write QA steps for a ticket. Use when the user asks for QA steps, testing instructions or a test plan for a ticket.
allowed-tools:
  - Read
  - Write
  - Bash(git log *)
  - Bash(git diff *)
  - Bash(git branch *)
  - Bash(git rev-parse *)
  - Bash(find *)
  - Bash(grep *)
  - Bash(ls *)
  - mcp__claude_ai_Linear__get_issue
  - ToolSearch
---

# /qa-steps

Arguments: `$ARGUMENTS` (the ticket key)

Write numbered steps a QA tester follows to confirm a ticket works. The
reader is on the business or QA team and knows the platform.

## Rules

- Write only `qa.md`. Never comment on the ticket or touch the tracker. The
  user pastes it.
- Take the key from the arguments, else the branch name. If neither has
  one, stop and say so.
- Cover the feature the ticket delivers. Leave out bugs unless the user
  names them.

## Steps

1. Find the ticket's files: a directory from
   `find .scratch -maxdepth 1 -type d -iname '<KEY>-<n>-*'`,
   else an epic's `issues/` file. Check the legacy `TT-<n>` key the same
   way, as `CLAUDE.local.md` maps it. Read the ticket, decisions and
   `changes.md`. If there are none, use `get_issue`.
2. Read `git log main..HEAD` and the ticket's diff, so each step matches
   what the code does. If the log is empty, stop and say the branch has no
   commits for the ticket. Where code and ticket disagree, write the code's
   behaviour and report the mismatch.
3. Write `qa.md` in the ticket's directory, or `qa/<KEY>-<n>-<slug>.md` in
   an epic, from the template. With neither, create
   `.scratch/<KEY>-<n>-<slug>/qa.md`.
4. Done when no step has "you", a named program, a navigation path or a
   bug.

## Template

```markdown
---
issue: <KEY>-<n>
status: ready-for-human
---

# <KEY>-<n> QA steps

**Setup:** flag `<flag>` on.

1. <Action>. <Expected result>.
```

- Setup names the flags and any data the tester needs. Drop it when there
  are none.
- One action and its expected result per step, as an instruction or a
  statement of what happens. Never "you", "let's" or "make sure".
- Say what to open, not how to reach it.
- Name no external programs.
- End with the flag-off check when a flag gates the feature.

```markdown
Bad:  1. Open Canvas Settings, either from the 3D canvas under "Utilities
         & Help" or from Settings, User, Canvas Settings.
Good: 1. Open 3D canvas settings.

Bad:  2. You should open the exports in CloudCompare to check them.
Good: 2. Open the exported point clouds. Colours are kept.
```

## Reply

```markdown
Wrote `<path>`.

- Code and ticket disagree: <what>.
```

Include the bullet only when it applies.
