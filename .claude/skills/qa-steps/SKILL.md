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

Write a short checklist a QA tester follows to confirm a ticket works. The
reader is on the business or QA team, knows the platform, and stops reading
a long list. Short beats complete.

## Rules

- Write only `qa.md`. Never comment on the ticket or touch the tracker. The
  user pastes it.
- Take the key from the arguments, else the branch name. If neither has
  one, stop and say so.
- Cover the feature the ticket delivers. Leave out bugs unless the user
  names them.
- Limits: setup in 3 lines or fewer, at most 10 steps under "Check", at
  most 5 lines under "Also worth a look". The whole file fits on one
  screen.

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
3. List the tests the diff adds (backend `test_*`, `*.cy.ts`) and what each
   asserts. Drop any step that only re-checks one of them: validation
   messages, sort order, overlap or count rules, single error states. Keep
   what a person judges better than a test: the end-to-end flow, how it
   looks, real accounts and permissions, the flag-off check.
4. Pick the main flow a user takes through the feature and write it under
   "Check". Put other worthwhile paths (another page, units, a related
   action) under "Also worth a look". Leave out the rest.
5. Write `qa.md` in the ticket's directory, or `qa/<KEY>-<n>-<slug>.md` in
   an epic, from the template. With neither, create
   `.scratch/<KEY>-<n>-<slug>/qa.md`.
6. Done when the limits hold and no step has "you", a named program, a
   navigation path, a bug or a field-by-field entry.

## Template

```markdown
---
issue: <KEY>-<n>
status: ready-for-human
---

# <KEY>-<n> QA steps

**Setup:** flag `<flag>` on. <The least data the steps need.>

## Check

1. <Action>. <What the tester sees>.

## Also worth a look

- <One line, no expected result unless it isn't obvious>.
```

- Setup names the flags and the least data the steps need. Reuse one
  record across steps, and describe data that likely exists already ("a
  scan with a start and end chainage") over data to build. Drop setup when
  there is none.
- Name every account the steps need by role ("an editor and a view-only
  user"), not just the unusual one.
- One user action per step, at the level the user thinks in ("Add an
  interval"), not each field. Never "you", "let's" or "make sure".
- The expected result is what the tester sees, in a short clause. Quote UI
  text only when the text is what's under test.
- Say what to open, not how to reach it.
- Name no external programs.
- End "Check" with the flag-off check when a flag gates the feature.
- Drop "Also worth a look" when it would be empty.

```markdown
Bad:  1. Open Canvas Settings, either from the 3D canvas under "Utilities
         & Help" or from Settings, User, Canvas Settings.
Good: 1. Open 3D canvas settings.

Bad:  2. You should open the exports in CloudCompare to check them.
Good: 2. Open the exported point clouds. Colours are kept.

Bad:  3. Type 100 for Start and 120 for End, then select Next. Step 2
         shows the RMR89 inputs. The Result line updates as inputs are
         filled in.
      4. Enter Start 150 and End 140. The form says "Start must be less
         than end."
Good: 3. Add an RMR89 interval over part of the scan. It shows in the
         table and on the strip.
```

## Reply

```markdown
Wrote `<path>`.

- Left out, covered by tests: <behaviours, one line>.
- Code and ticket disagree: <what>.
```

Include each bullet only when it applies.
