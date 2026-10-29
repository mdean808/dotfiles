---
name: mr-desc
description: Write an MR description. Use when the user asks for an MR, merge request or PR description.
allowed-tools:
  - Read
  - Write
  - Bash(git status *)
  - Bash(git branch *)
  - Bash(git log *)
  - Bash(git show *)
  - Bash(git diff *)
  - Bash(git rev-parse *)
  - Bash(find *)
  - Bash(grep *)
  - Bash(ls *)
  - ToolSearch
  - AskUserQuestion
---

# /mr-desc

Write the MR description, ready to paste into GitLab. The reader is a
teammate who wants to know what changed and that it is tested. The diff
shows how; never repeat it.

## Rules

- Write only the output file. No commits, pushes, MRs or tracker writes.
- Take the tracker and `<KEY>` from the "Issue tracker" table in
  `CLAUDE.local.md`. Not Linear, or no table: say so and stop.
- Run paths from `git rev-parse --show-toplevel`.
- When the diff and the notes disagree, describe the diff.

## Steps

1. **Ticket.** Take the key from the arguments, else the branch name, else
   ask. Resolve a legacy key to its `<KEY>` issue as `CLAUDE.local.md`
   says. Find the ticket's files as the global `scratch-workflow.md` rule
   says: a directory from
   `find .scratch -maxdepth 1 -type d -iname '<key>-<n>-*'`, else an epic's
   `issues/` file from
   `grep -rliE '^(issue|linear): *<key>-<n> *$' .scratch/*/issues/`, then
   both again with the legacy key. None: ask. Never guess one.

   A standalone ticket's output file is `mr.md` in its directory. A ticket
   in an epic writes `mrs/<name>.md` in the epic's directory, where `<name>`
   is its `issues/` file's name.
2. **Gather.** Read `git log main..HEAD`, `git diff main...HEAD` (every
   hunk), `git status`, and the ticket's scratch files (in an epic: its
   `issues/`, `decisions/` and `plans/` files, and its section of
   `changes.md`). No ticket file: fetch the issue with `get_issue`.
   Uncommitted changes are left out of the description.
3. **Tests.** Don't run them. Ask with AskUserQuestion: "All green",
   "Some failing" or "Not run yet".
4. **Write** to the template below. Drop empty sections, headings included.
5. **Check** every sentence against a hunk, a results file or the answer
   to step 3. Cut what you can't point to. Cut anything from the scratch
   notes that is not for the team: agent assumptions, private details,
   secrets. If the output file exists, ask before replacing it.
6. **Reply** as below, and nothing else.

## Template

````markdown
# <KEY>-<n> <What the MR does>

<Summary>

## Changes

- <change>

## Results

<table>

## Database

- <migration>

## Testing

<sentence>

## Future work

<sentence>
````

**Title.** The key and what the MR does, sentence case. A bug names the
fix: `GRO-12 Fix the Profile project dropdown for masquerading superusers`.

**Summary.** One sentence on what a user would notice, and the flag if one
gates it. A second only for measured proof.

```markdown
Bad:  Project admins can now version frameworks, which means past
      assessments stay accurate after a formula changes.
Good: Project admins can turn RMC frameworks on or off and keep editing one
      after windows are assessed with it, behind flag TT-1164.
```

**Changes.** One bullet per feature, named the way a reviewer would sum it
up out loud. One sentence, starting with a verb. At most five. Nothing the
diff or ticket already shows: no endpoints, no fields, no rules for edge
cases. Commits outside the ticket go in a final `Also:` bullet.

```markdown
Bad:
- Turn custom frameworks on or off per project, and archive one with
  assessed windows instead of deleting it. Restore keeps its on or off
  setting.
- Turn built-in RMR89, Q, Q' and GSI on or off per project
  (`GET`/`PATCH api/rmc-frameworks/built-in/`).
- Fix the Profile project dropdown: `get_active_project` now reads the
  masqueraded user's memberships.

Good:
- Turn custom frameworks on or off per project, and archive one with
  assessed windows instead of deleting it.
- Turn built-in RMR89, Q, Q' and GSI on or off per project.
- Fix saving the active project while masquerading.
```

**Results.** Only with measurements in a results file. One sentence on the
dataset, then one table per metric. Copy the numbers; compute only the
change column, to one decimal place.

```markdown
| endpoint                   | baseline | final | change |
| -------------------------- | -------: | ----: | -----: |
| `GET /reports/api/window/` |    4,268 |    30 | -99.3% |
```

**Database.** One bullet per migration: its name and what it changes. Add
one sentence only if it backfills data, can't be reversed, or must deploy
in a set order.

**Testing.** Which kinds of test cover it, then the step 3 answer: "All
tests pass.", "<n> tests fail: <which>.", or nothing. Never list files.

```markdown
Covered by Django API tests and Cypress component tests. All tests pass.
```

**Future work.** Only a follow-up ticket by key, or a limit the MR leaves
in the problem it solves. In doubt, leave it out.

**Writing.** Wrap at 80 characters. Write a flag as "flag GRO-77". Use the
terms in `CONTEXT.md`. Never write: implementation history, decisions made
while building, copy changes, what stayed the same, file walkthroughs, or
the GitLab template's checklist.

## Reply

````markdown
Wrote `<output file>`.

- Commits outside the ticket: <sha subject>, in the `Also:` bullet.
- Uncommitted changes, left out: <files>.
````

Include a bullet only when it applies.
