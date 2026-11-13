---
name: mr-desc
description: Write an MR description. Use when the user asks for an MR, merge request or PR description.
---

# mr-desc

Write an MR description. The reader is a teammate who wants to know what changed.
The git diff shows exactly what changed; do not repeat it.

## Rules

- Write only the output file. No commits, pushes, MRs or tracker writes.
- Take the tracker and `<KEY>` from the "Issue tracker" table in
  `CLAUDE.local.md`.
- Run paths from `git rev-parse --show-toplevel`.
- When the diff and notes or documentation disagree, defer to the diff.

## Steps

1. **Ticket.** Take the key from the branch name, or ask.
   Find the ticket's files as the global `scratch-workflow.md` rule
   says: a directory from
   `find .scratch -maxdepth 1 -type d -iname '<key>-<n>-*'`, else an epic's
   `issues/` file from
   `grep -rliE '^(issue|linear): *<key>-<n> *$' .scratch/*/issues/`.
   None: ask. Never guess one.

   A standalone ticket's output file is `mr.md` in its directory. A ticket
   in an epic writes `mrs/<name>.md` in the epic's directory, where `<name>`
   is its `issues/` file's name.

2. **Gather.** Read `git log main..HEAD`, `git diff main...HEAD` (every
   hunk), `git status`, and the ticket's scratch files (in an epic: its
   `issues/`, `decisions/` and `plans/` files, and its section of
   `changes.md`). No ticket file: fetch the issue with `get_issue`.
3. **Tests.** Don't run them. Ask with AskUserQuestion: "All green",
   "Some failing" or "Not run yet".
4. **Write** to the template below. Drop empty sections, headings included.
5. **Check** every sentence against a hunk, a results file or the answer
   to step 3. Cut what you can't point to. Cut anything from the scratch
   notes that is not for the team: agent assumptions, private details,
   secrets. If the output file exists, ask before replacing it.
6. **Read it back.** Read the title, summary and each bullet as if saying
   them to a teammate at their desk. Rewrite any sentence you'd run out of
   breath on, any sentence joined with a semicolon, and any run of
   sentences with the same length and shape.
7. **Reply** as below, and nothing else.

## Template

```markdown
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

## Merge request checklist

[x] Code meets completion criteria for this change

[x] Cypress tests have been run and passed locally (or in CI)

[x] If this MR adds a migration or touches a flagged data path: ./devtools.sh lint-migrations passes, and the migration checklist is complete
```

**Title.** The key and what the MR does, sentence case. A bug names the
fix: `GRO-12 Fix the Profile project dropdown for masquerading superusers`.

**Summary.** A short paragraph of two or three sentences. Start with the
problem the ticket describes, in its words. Then say what a user will
notice now, and end with the flag if one gates it. Add a sentence only for
measured proof. If the ticket states no problem, skip it; never invent a
reason. Let sentence length vary, and never join clauses with a semicolon.

```markdown
Bad: Project Overview no longer shows the report settings card, and Edit
Project calls the group Report Content; a Rock Mass Classification
Frameworks card takes its place behind flag TT-1164.

Good: Report settings sat on Project Overview under the label Report
Aesthetic, which users found unclear and out of place. They now live only
in Edit Project, as Report Content. Behind flag TT-1164, the project's RMC
frameworks take the card's place.
```

**Changes.** One bullet per feature, named the way a reviewer would sum it
up out loud. Start with a verb. One idea per bullet; a few words is fine.
Name the main screen a change touches, not every one. At most five.
Nothing the diff or ticket already shows: no endpoints, no fields, no
rules for edge cases. Commits outside the ticket go in a final `Also:`
bullet, however big they are.

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

```markdown
Bad:

- Speed up selecting, filtering and searching on long capture lists in All
  Data, Browse by location, the Add Data modal and the upload page.

Good:

- Also: speed up long capture lists, such as All Data's.
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

**Checklist.** Tick the Cypress line only when the step 3 answer is "All
green"; otherwise leave it `[ ]`.

**Writing.** Wrap at 80 characters. Write a flag as "flag GRO-77". Use the
terms in `.local/CONTEXT.md`. Never write: implementation history,
decisions made while building, copy changes, what stayed the same, or file
walkthroughs.

## Reply

```markdown
Wrote `<output file>`.

- Uncommitted changes, left out: <files>.

<markdown code block containing result>
```

Include a bullet only when it applies.
