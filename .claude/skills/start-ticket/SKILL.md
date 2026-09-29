---
name: start-ticket
description: Start work on a TT Jira ticket. Picks the ticket (a given key, or
  your next In Progress or To Do ticket by priority), creates its branch,
  moves it to In Progress in Jira, sets up its .scratch/ directory with a ticket
  snapshot, briefs you on the ticket, and offers a grilling session. Use when
  the user says to start, pick up or begin a ticket, or asks what to work on
  next.
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
  - mcp__claude_ai_Atlassian__getJiraIssue
  - mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql
  - mcp__claude_ai_Atlassian__atlassianUserInfo
  - mcp__claude_ai_Atlassian__getTransitionsForJiraIssue
  - mcp__claude_ai_Atlassian__transitionJiraIssue
---

# /start-ticket

Arguments: `$ARGUMENTS`

## The result: a ticket brief

The user runs this skill to learn what a ticket is about before working on
it. The **brief** below is the result. The branch, Jira and scratch setup is
narration: one or two sentences after the brief. Under a concise output style,
"lead with the result" means lead with the brief.

```markdown
**TT-<n>: <title>**
type: <issue type>
priority: <priority>
branch: <branch>
<Jira link>

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
- <TT-xxx (<link type>): what it adds, in one line>

---

<Setup: why this ticket was picked, whether the branch was created or checked
out, what happened in Jira, and the ticket.md path, new or reused.>

Start a grilling session?
```

Write the brief for fast reading:

- Rephrase the ticket in short sentences, one fact per sentence or bullet.
  Split anything the ticket runs together (conditions, symptoms, outcomes)
  into separate bullets.
- When the ticket offers alternative outcomes, number them under Expected,
  one per line.
- Leave out any section the ticket has nothing for, headings included.
- Related holds duplicates, linked issues, the parent and subtasks, plus any
  other metadata that bears on the work. It is the last section before the
  setup.
- Skip who reported the ticket, where and when.
- For a story or task, replace Conditions, Steps to reproduce, Expected and
  Actual with **User story** (the "As a ... I want ... so that ..." line, if
  any) and **Today** (how things work now).
- Use the terms in `.local/CONTEXT.md` when it exists.
- A flagged ticket (In Review, Done, Cancelled, or assigned to someone else)
  leads the setup sentences with that fact.

The brief is a plain text reply that ends your turn. It closes with the line
"Start a grilling session?" and nothing after it: no tool call, no list of
open points.

Done when: your final message opens with the `**TT-<n>: <title>**` line and
the problem sentences, and ends with "Start a grilling session?".

## Ground rules

- Jira is read-only except for one write the user has pre-approved: moving
  their own To Do ticket to In Progress (step 5). Make that move without
  asking. Every other Jira write stays off limits.
- Use `cloudId: groundedai.atlassian.net`. Load the Atlassian tool schemas
  with one ToolSearch call before the first Jira call.
- Run every path relative to the repo root (`git rev-parse --show-toplevel`).

## Steps

### 1. Pick the ticket

A ticket named in the arguments or the message (`TT-123`, `tt-123`, `123`) is
the ticket. Otherwise run these in order and stop at the first that returns
anything:

1. `project = TT AND assignee = currentUser() AND status = "In Progress"
   ORDER BY priority DESC, key ASC`
2. `project = TT AND assignee = currentUser() AND status = "To Do"
   ORDER BY priority DESC, key ASC`

Take the highest priority, then the lowest number, checking Jira's sort
yourself. Note why it won for the setup sentences. Match statuses by name:
In Review shares Jira's "In Progress" category and is not a ticket to start.

Both empty: tell the user no TT ticket in In Progress or To Do is assigned to
them, and stop.

### 2. Fetch it

`getJiraIssue` with `responseContentFormat: markdown` and fields `summary,
description, status, priority, issuetype, assignee, labels, components,
parent, subtasks, issuelinks, comment, updated`. Compare the assignee with the
`accountId` from `atlassianUserInfo`.

The ticket does not exist: say so and stop.

### 3. Choose the slug

The branch and scratch directory share one slug. First match wins:

1. An existing branch: `git branch -a --list '*TT-<n>-*' '*tt-<n>-*'`. If
   several match, ask which one.
2. An existing scratch directory:
   `find .scratch -maxdepth 1 -type d -iname 'tt-<n>-*'`.
3. New: 3 to 6 lowercase kebab-case words naming the change.

### 4. Set up the branch

An existing branch from step 3 is used as it is. A new one is
`<type>/TT-<n>-<slug>`: `bug` for a Bug ticket, `feat` for anything else.

Run `git status` first. Uncommitted changes, or a rebase or merge in progress:
show the user and ask how to proceed before switching.

- On the branch already: nothing to do.
- Local branch exists: `git switch <branch>`.
- Only `origin/<branch>` exists: `git switch <branch>`.
- New: `git fetch origin main`, then
  `git switch --no-track -c <branch> origin/main`.

Done when: `git branch --show-current` prints the ticket's branch.

### 5. Move it to In Progress

Only when the ticket is in To Do and assigned to the user. Call
`getTransitionsForJiraIssue`, take the transition whose `to.name` is
`In Progress`, and pass its `id` to `transitionJiraIssue`. No such transition,
or a failed call: note it for the setup sentences and carry on.

### 6. Write the ticket snapshot

Confirm `.scratch/` is listed in
`$(git rev-parse --git-common-dir)/info/exclude` and add it if missing. Reuse
the step 3 directory under its current name, or create
`.scratch/TT-<n>-<slug>/`.

An existing `ticket.md` stays as it is; if Jira's `updated` date is later than
its snapshot date, mention that it may be stale. Otherwise write `ticket.md`
as a verbatim copy of Jira, leaving out empty sections:

```markdown
---
jira: TT-<n>
status: needs-triage
---

# TT-<n>: <summary>

- Type: <issue type>
- Priority: <priority>
- Jira status: <status after step 5>
- Assignee: <name>
- Parent: <key>: <summary>
- Link: https://groundedai.atlassian.net/browse/TT-<n>
- Snapshot taken: <YYYY-MM-DD>

## Description

<description, verbatim>

## Linked issues

- <key> (<link type>): <summary>

## Jira comments

**<author>, <YYYY-MM-DD>:** <body>
```

Other skills append conversation under `## Comments`, so keep that heading
free. The rest of the directory layout follows
`.local/docs/agents/issue-tracker.md`.

### 7. Send the brief

Reply with the brief from the top of this skill and end your turn.

### 8. Grill, if the user says yes

When the user answers yes, invoke `mattpocock-skills:grilling` (`grill-me` is
user-invoked only and calls it) with the ticket key and the `ticket.md` path.
Spec and issue files from the session go under the ticket's scratch
directory, as `.local/docs/agents/issue-tracker.md` describes.
