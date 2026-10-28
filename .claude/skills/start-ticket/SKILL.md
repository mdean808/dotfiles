---
name: start-ticket
description: Start work on a ticket. Use when the user asks to start or pick up a ticket, or what to work on next.
allowed-tools:
  - Read
  - Write
  - Bash(git status *)
  - Bash(git branch *)
  - Bash(git fetch *)
  - Bash(git switch *)
  - Bash(git rev-parse *)
  - Bash(find *)
  - Bash(mkdir *)
  - ToolSearch
  - AskUserQuestion
  - Skill
  - mcp__claude_ai_Linear__get_issue
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Linear__list_comments
  - mcp__claude_ai_Linear__list_cycles
  - mcp__claude_ai_Linear__list_projects
  - mcp__claude_ai_Linear__get_user
  - mcp__claude_ai_Linear__save_issue
---

# /start-ticket

Arguments: `$ARGUMENTS`

## The result: a ticket brief

The user runs this skill to learn what a ticket is about before working on
it. The **brief** below is the result. The branch, tracker and scratch setup
is narration: one or two sentences after the brief. Under a concise output
style, "lead with the result" means lead with the brief.

```markdown
**<KEY>-<n>: <title>**
type: <type label>
priority: <priority>
branch: <branch>
<issue link>

<One or two short sentences: what is wrong or missing.>

**Conditions**
- <a role, flag or data setup the problem needs>

**Steps to reproduce**
1. <step>

**Expected**
- <one outcome per bullet>

**Actual**
- <one symptom per bullet>

**Acceptance criteria**
- <criterion>

**Related**
- <KEY-xxx (<relation>): what it adds, in one line>

---

<Setup: why this ticket was picked, whether the branch was created or checked
out, what happened in the tracker, and the ticket file's path, new or reused.>

Start a grilling session?
```

Write the brief for fast reading:

- Rephrase the ticket in short sentences, one fact per sentence or bullet.
  Split anything the ticket runs together (conditions, symptoms, outcomes)
  into separate bullets.
- When the ticket offers alternative outcomes, number them under Expected,
  one per line.
- Leave out any section the ticket has nothing for, headings included.
- Related holds duplicates, related and blocking issues, the parent,
  sub-issues and the project, plus any other metadata that bears on the work.
  It is the last section before the setup.
- Skip who reported the ticket, where and when, and the legacy-key line at the
  top of a migrated description.
- For a story or task, replace Conditions, Steps to reproduce, Expected and
  Actual with **User story** (the "As a ... I want ... so that ..." line, if
  any) and **Today** (how things work now).
- Use the terms in `CONTEXT.md` at the repo root when it exists.
- A flagged ticket (In Review, Done, Canceled, Duplicate, or assigned to
  someone else) leads the setup sentences with that fact.

The brief is a plain text reply that ends your turn. It closes with the line
"Start a grilling session?" and nothing after it: no tool call, no list of
open points.

Done when: your final message opens with the `**<KEY>-<n>: <title>**` line
and the problem sentences, and ends with "Start a grilling session?".

## Ground rules

- Read the "Issue tracker" table in `CLAUDE.local.md` at the repo root first.
  It gives the tracker, `<KEY>`, the issue URL, the statuses and the legacy
  key. This skill supports Linear. Any other tracker, or no table: say so and
  stop.
- The tracker is read-only except for one write the user has pre-approved:
  moving their own Todo ticket to In Progress (step 5). Make that move without
  asking. Every other tracker write stays off limits.
- Load the Linear tool schemas with one ToolSearch call before the first
  Linear call.
- Run every path relative to the repo root (`git rev-parse --show-toplevel`).

## Steps

### 1. Pick the ticket

A ticket named in the arguments or the message is the ticket:

- `<KEY>-123`, `<key>-123` or `123`: that issue.
- A legacy key (`TT-123`): find its `<KEY>` issue as `CLAUDE.local.md` says.
  None found: say so and stop. Name both keys in the setup sentences.

Otherwise find the team's current cycle (`get_user` with `me` gives the team
id; `list_cycles` with it and `type: current`), then run these `list_issues`
calls in order and stop at the first that returns anything. Both use
`team: <KEY>`, `assignee: me`, the cycle's id, and fields `title, status,
priority, labels`:

1. `state: In Progress`
2. `state: Todo`

Take the highest priority (1 Urgent is highest, 0 None is lowest), then the
lowest number. Note why it won for the setup sentences. In Review is a
started state too and is not a ticket to start.

Both empty: tell the user no `<KEY>` ticket in In Progress or Todo in the
current cycle is assigned to them, and stop.

A ticket picked by search needs the user's approval before any later step
runs. Ask with AskUserQuestion: the first option is the picked ticket
(`<KEY>-<n>: <title>`, with its priority, status and why it won), then up to
three runners-up from the same search results. Continue with the ticket the
user chooses. A ticket the user names in "Other" is treated as a named ticket.
A named ticket skips this approval.

### 2. Fetch it

`get_issue` with `includeRelations: true` and fields `title, description,
status, priority, labels, assignee, parentId, project, url, attachments,
relations, updatedAt`. Then `list_comments` with the issue id. Compare the
assignee with `get_user` `me`.

The type is the issue's type label (`Bug`, `Feature`, `Improvement`, `Spike`,
`Maintenance`).

A description whose first line is `Jira: [TT-<n>](…)` carries the ticket's
legacy key. Note it for steps 3 and 6.

The ticket does not exist: say so and stop.

### 3. Choose the slug

The branch and the ticket's scratch files share one slug. First match wins,
checking the `<KEY>-<n>` key and then the legacy key:

1. An existing branch: `git branch -a --list '*<KEY>-<n>-*' '*<key>-<n>-*'`.
   If several match, ask which one.
2. An existing scratch directory:
   `find .scratch -maxdepth 1 -type d -iname '<key>-<n>-*'`.
3. An `issues/` file in an epic's directory whose frontmatter names the key:
   `grep -rliE '^(issue|linear|legacy|jira): *<key>-<n> *$' .scratch/*/issues/`.
   The slug is the file name without its key, number or `draft-` prefix.
4. New: 3 to 6 lowercase kebab-case words naming the change.

Note which of 2 and 3 matched, if either: step 6 uses it. Both matching
means the ticket was set up twice; ask which to keep.

Ignore Linear's suggested `gitBranchName`; it does not follow the repo's
naming rule.

### 4. Set up the branch

An existing branch from step 3 is used as it is, legacy name included. A new
one is `<type>/<KEY>-<n>-<slug>`: `bug` for a ticket labelled `Bug`, `feat`
for anything else.

Run `git status` first. Uncommitted changes, or a rebase or merge in progress:
show the user and ask how to proceed before switching.

- On the branch already: nothing to do.
- Local branch exists: `git switch <branch>`.
- Only `origin/<branch>` exists: `git switch <branch>`.
- New: `git fetch origin main`, then
  `git switch --no-track -c <branch> origin/main`.

Done when: `git branch --show-current` prints the ticket's branch.

### 5. Move it to In Progress

Only when the ticket is in Todo or Backlog and assigned to the user:
`save_issue` with the issue id and `state: In Progress`. A failed call: note
it for the setup sentences and carry on.

### 6. Write the ticket snapshot

Confirm `.scratch` is listed in
`$(git rev-parse --git-common-dir)/info/exclude` and add it if missing. The
layout follows the global `scratch-workflow.md` rule.

**A ticket in an epic** (step 3 matched an `issues/` file) keeps its files in
the epic's directory, and its `issues/` file is its ticket file. Write no
separate snapshot.

- If the file is not yet named `<KEY>-<n>-<slug>.md` (an `NN-` or `draft-`
  name), rename it and every file named after it in the epic's other
  subdirectories, and rewrite any `blocked-by` that points at its old number
  or name. Tell the user what was renamed.
- Set its frontmatter `issue:` to the key, and `legacy:` when there is one.
  Leave the rest as it is.
- If the issue's `updatedAt` is later than the file's last change, mention
  that the tracker may have moved on.

**A standalone ticket** reuses the step 3 directory under its current name,
or creates `.scratch/<KEY>-<n>-<slug>/`, and its ticket file is `ticket.md`.

An existing `ticket.md` stays as it is; if the issue's `updatedAt` is later
than its snapshot date, mention that it may be stale. A `ticket.md` taken
from the legacy tracker also stays, and the setup sentences say the Linear
issue may have moved on since. Otherwise write `ticket.md` as a verbatim copy
of the issue, leaving out empty sections:

```markdown
---
issue: <KEY>-<n>
legacy: TT-<n>
status: needs-triage
---

# <KEY>-<n>: <title>

- Type: <type label>
- Labels: <other labels>
- Priority: <priority>
- Status: <status after step 5>
- Assignee: <name>
- Project: <project>
- Parent: <key>: <title>
- Link: <issue URL>
- Snapshot taken: <YYYY-MM-DD>

## Description

<description, verbatim>

## Linked issues

- <key> (<relation>): <title>

## Tracker comments

**<author>, <YYYY-MM-DD>:** <body>
```

Drop the `legacy:` line when there is no legacy key.

Other skills append conversation under `## Comments`, so keep that heading
free.

### 7. Send the brief

Reply with the brief from the top of this skill and end your turn.

### 8. Grill, if the user says yes

When the user answers yes, invoke `mattpocock-skills:grilling` (`grill-me` is
user-invoked only and calls it) with the ticket key and the ticket file's path.

When the user confirms a shared understanding, write the session's output as
the global `scratch-workflow.md` rule lays out. Never write a spec.

- **Decisions**: `decisions.md` beside `ticket.md`, or
  `decisions/<KEY>-<n>-<slug>.md` in an epic. Record each settled decision
  with its reason, the constraints the code must keep, and the test list.
  Quote the user only where they typed something other than a plain yes.
- **Plan**: `plan.md`, or `plans/<KEY>-<n>-<slug>.md` in an epic. Write thin
  vertical slices with blocking edges, and only when the work needs more than
  one slice. Offer `/to-tickets` instead if the user wants tracker
  sub-issues.
