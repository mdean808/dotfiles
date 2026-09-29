---
name: mr-description
description: Write a GitLab merge request description for the current branch's
  TT ticket into .scratch/<ticket>/mr.md, built from the branch diff, commits
  and the ticket's scratch notes. Use when the user asks for an MR, merge
  request or PR description (or "desc"), an MR write-up, or to get a branch
  ready for review.
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
  - Bash(ls *)
  - ToolSearch
  - AskUserQuestion
  - Skill
  - mcp__claude_ai_Atlassian__getJiraIssue
---

# /mr-description

Arguments: `$ARGUMENTS`

## The result

`.scratch/<ticket dir>/mr.md`, ready to paste into GitLab. The reply names the
file and flags what the MR carries beyond the ticket. It does not repeat the
description.

The reader is a teammate opening the MR. They want to know what changed and
that it is tested. They do not want the history of how the work was done, or
a walkthrough of what the diff already shows.

## Ground rules

- Read-only everywhere except `mr.md`. No commits, no pushes, no
  `glab mr create`, no Jira writes.
- Run every path relative to the repo root (`git rev-parse --show-toplevel`).
- The diff is the truth. Tickets, specs and change notes are intent, and they
  go stale. When they disagree with the diff, describe the diff.
- Apply the `unslop` skill to everything you write.

## Steps

### 1. Find the ticket

A key in the arguments (`TT-123`, `tt-123`, `123`) wins. Otherwise take it
from `git branch --show-current`. No key either way: ask for one.

The ticket directory is
`find .scratch -maxdepth 1 -type d -iname 'tt-<n>-*'`. None: ask for the
slug. Do not create a directory under a guessed name.

### 2. Gather

Read all of these that exist:

- `git log main..HEAD --format='%h %s%n%b'`
- `git diff main...HEAD --stat`, then the full diff. Read every hunk.
- `git status`. Uncommitted changes are not in the MR. Note them for the reply
  and describe only what is committed.
- In the ticket directory: `ticket.md`, `spec.md`, `changes.md`,
  `results.md`, `issues/*.md`, and any benchmark results.
- An existing `mr.md`: see step 4.

No `ticket.md`: fetch the issue with `getJiraIssue` (`cloudId:
groundedai.atlassian.net`, `responseContentFormat: markdown`, fields
`summary, description, issuetype, issuelinks`). Load the tool schema with
ToolSearch first.

Sort every commit into one of two groups: the ticket's work, and anything
else (a rules tweak, an unrelated fix). Anything else still ships with the MR,
so it still gets described. Flag it in the reply.

### 3. Ask about the tests

Do not run the test suite. Ask with AskUserQuestion whether all tests pass,
with the options "All green", "Some failing" and "Not run yet". The answer
decides the last sentence of Testing.

### 4. Write

Follow the template and the rules under it. Leave out any section with
nothing in it, heading included.

````markdown
# TT-<n> <What the MR does>

<Summary.>

## Changes

### Backend

- <change>

### Frontend

- <change>

## Results

<Measurements, when the work has them.>

## Database

- <migration>

## Testing

<Two or three sentences.>

## Future work

<What is still left.>
````

**Title.** `TT-<n>` and a short phrase for what the MR does, sentence case.
Use the commit subject when it already says this. For a bug, name the fix
("Fix Profile project dropdown for masquerading superusers"), not the
symptom.

**Summary.** One sentence saying what the MR does, in terms a user or caller
would notice. Stop at the change itself; the reader infers its consequences,
such as a saved setting surviving a refresh. Add a second sentence only for
measured evidence that it works or is safe ("Response bodies are
byte-for-byte identical before and after on every benchmarked case.").

**Changes.**

- One bullet per behaviour change, not per file or per commit.
- Open with an imperative verb: Add, Fix, Prefetch, Clear, Stop.
- Say what changed and, where it isn't obvious, the effect: "so we no longer
  have to pull the window list on project page load."
- For a bug fix, name the fix ("Fix saving the active project while
  masquerading") and give the rest of the bullet to what the code does now.
- Put endpoints, components, fields and flags in backticks. Leave out file
  paths and line numbers unless the file itself is the change.
- Group under `### Backend`, `### Frontend`, `### CI` and `### Other`, in
  that order. With only one group, drop the subheading and use a flat list.
- Tests and test fixtures go under Testing, not here.
- Commits outside the ticket go under `### Other`.

**Results.** Only when there are measurements: benchmarks, query counts,
timings, sizes. Give the dataset in one sentence, then one table per metric:

```markdown
| endpoint                    | baseline | final | change |
| --------------------------- | -------: | ----: | -----: |
| `GET /reports/api/window/`  |    4,268 |    30 | -99.3% |
```

Copy numbers from the results files; never compute or round them yourself
beyond the change column (one decimal place). Pad columns so the raw markdown
lines up.

**Database.** Only when the diff adds a migration or changes a model's
fields, constraints, indexes or row-level security. One bullet per migration:
its name and what it changes. Add a sentence when a migration backfills or
rewrites data, is not reversible, or has to be deployed in a particular order
with the code.

**Testing.** A summary, never a list of test files. Say which kinds of test
cover the changes ("Covered by Django and Cypress tests."). Add one sentence when running the tests needs a
step beyond the usual, such as reseeding the E2E database. End with the
answer from step 3:

- All green: "All tests pass."
- Some failing: "<n> tests fail: <which>." Ask the user for which if you
  don't know.
- Not run yet: no sentence.

**Future work.** Only work someone is expected to pick up: a follow-up ticket
by key, or a limit the MR leaves in the problem it solves (for example, an
endpoint still too slow at scale). Leave out code that was deliberately left
alone, adjacent issues nobody plans to fix, and decisions recorded in the
spec. When in doubt, leave the section out.

**Writing.**

- Wrap prose at 80 characters. Tables and headings stay on one line.
- Write only what the reader can't infer. Cut any clause that follows from
  the rest of the sentence, and any mention of what stays the same unless a
  reviewer would expect it to change.
- Use the usual developer term over a paraphrase: "revert the select", not
  "put the select back".
- Write a feature flag's key as "flag TT-820", so it reads as a flag and not
  a ticket.
- Use the domain terms in `.local/CONTEXT.md` when it exists.
- No implementation history: no "first tried X", no reverted work, no
  process notes from `changes.md`.
- No file-by-file walkthrough; the diff has that.
- Leave out the checklist from `.gitlab/merge_request_templates/Default.md`.

### 5. Save

Write `.scratch/<ticket dir>/mr.md`. When one exists already, compare it with
your draft and ask before replacing it; the user may have edited it by hand.

Before saving, check every claim in the draft against the diff. Drop or
rewrite any sentence you cannot point to a hunk, a results file or the
user's answer in step 3 for.

### 6. Reply

````markdown
Wrote `.scratch/<ticket dir>/mr.md`.

<Only when they apply, one bullet each:>
- Commits outside the ticket: <sha subject>, described under Other.
- Uncommitted changes, left out of the description: <files>.
````

Nothing else: no notes on where the spec and diff disagree, no list of
unconfirmed claims, no summary of the description.
