# Ticket workflow in `.scratch/`

Applies to every repo on this machine. The repo's `CLAUDE.local.md` names the
tracker, its `<KEY>` and any legacy key in an "Issue tracker" table. Everything
else about tickets, plans and notes is defined here. Detail lives in
`~/.claude/docs/agents/`.

## The tracker is read-only

Never create, edit, transition, comment on or label a tracker issue unless the
user gives permission. Where a skill says to write to the tracker, write a
markdown file under `.scratch/` instead, and the user promotes it by hand.
`/start-ticket` may move the user's own unstarted ticket to In Progress.

## Grilling produces decisions and a plan, not a spec

A spec reads as a contract, and the finished work is never one-to-one with it:
feedback, progress and design limits change it as it is built. So a grilling
session writes two files:

- **Decisions**: each settled decision, its reason, and any constraint the
  code must keep (security, scoping, data integrity, flags), plus the test
  list. It is kept current: when feedback reverses a decision, edit or strike
  the entry in the same step. Never leave a stale one.
- **Plan**: thin vertical slices, each testable on its own, with blocking
  edges. It is disposable. Nobody checks the code against it, and it is not
  updated as the work drifts.

Skills that ask for a spec (`/implement-spec`, `/to-tickets`) take the
decisions file as the spec. `/to-tickets` writes its slices into the plan, not
into `issues/`, unless the user asks for tracker sub-issues.

## Working on a ticket

When a skill fetches a ticket or implements one (`/implement`,
`/implement-spec`, `/tdd`), find its files as the layout below says and read:

- the issue file (`issues/<KEY>-<n>-<slug>.md`) or `ticket.md`,
- the decisions file,
- the plan,
- the ticket's section of `changes.md`,
- the tracker issue, for anything newer than the files.

Where they disagree, the decisions file wins over the issue's acceptance
criteria only where a decision explicitly changes a criterion, since it
records changes the user approved. Otherwise the criteria hold. Both win over
the plan, and `changes.md` entries are approved amendments to both. Work the plan's slices in
order of their blocking edges. Pass `/implement` the ticket key, not the plan
path.

## What a review checks against

The Spec axis of any review (`/code-review`, a review subagent) checks the code
against, in this order: the ticket's acceptance criteria, the decisions file,
and `changes.md`. Entries in `changes.md` are approved amendments, not scope
creep. The plan is never a review source.

## Tests

The decisions file's test list is the full set of tests to write. A test not
on it needs an explicit yes, and a yes adds it to the list. Prefer extending an
existing test over adding a new one. Before reporting a ticket done, list every
test the change added next to that list, with a one-line reason for each test
it doesn't name.

## Layout

A standalone ticket has its own directory:

    .scratch/<KEY>-<n>-<slug>/
      ticket.md       tracker snapshot
      decisions.md
      plan.md
      changes.md
      mr.md

A ticket in an epic or project lives in the epic's directory, with every
per-ticket file named after the ticket:

    .scratch/<epic-key>-<n>-<slug>/
      ticket.md       the epic's snapshot
      decisions.md    epic-wide decisions
      changes.md      one section per ticket
      issues/<KEY>-<n>-<slug>.md       the ticket
      decisions/<KEY>-<n>-<slug>.md
      plans/<KEY>-<n>-<slug>.md
      mrs/<KEY>-<n>-<slug>.md

- A file for a ticket with a tracker issue is named `<KEY>-<n>-<slug>.md`.
  Never `01-<slug>.md`.
- A ticket not yet in the tracker is `issues/draft-<slug>.md`. When the user
  files it, rename it and every file named after it, then update every
  `blocked-by` that points at it.
- `blocked-by` lists keys (`[GRO-53, draft-lithos-forms]`), never positions.
  Tracker numbers don't follow dependency order, so the edges are the order.
- To find a ticket's files, look for a top-level directory named
  `<key>-<n>-*`, then for an `issues/` file whose frontmatter `issue:` is the
  key. Check the legacy key the same way. Reuse what you find; never start a
  second directory for a ticket an epic already holds.
- Directories named before a tracker move keep their legacy key. Older
  `specs/` files stay as they are and count as decisions files.
- Unticketed bugs go in `.scratch/bugs/<slug>.md`, one per bug, with
  `status: needs-triage` and no `issue:` key. Search the tracker and
  `.scratch/bugs/` first. Once filed, the bug moves to its ticket directory.
- QA notes are `qa.md` beside the ticket's other files (`qa/<KEY>-<n>-<slug>.md`
  in an epic).

## Frontmatter

Every file opens with frontmatter:

    ---
    issue: GRO-54
    legacy: TT-1166
    parent: GRO-12
    status: needs-triage
    blocked-by: [GRO-53]
    ---

- Drop the keys that don't apply. Older files may use `jira:` or `linear:`;
  read them as `legacy:` and `issue:`.
- `status:` holds the triage role, never a tracker label: `needs-triage`,
  `needs-info`, `ready-for-agent`, `ready-for-human` or `wontfix`. When a skill
  says to apply a triage label, set `status:`.
- When the user asks to commit work from a ticket, tick its met acceptance
  criteria in the issue file and set `status: done` in the same step.

## Writing in these files

- Conversation appends under a `## Comments` heading at the bottom.
- Only text the user typed may be attributed to them, quoted verbatim. Your own
  reading goes under `## Agent assumptions (unconfirmed)`.

## Change notes

After `/implement`, append anything the work did that the ticket didn't ask for
to the ticket's `changes.md`. Format: `~/.claude/docs/agents/change-notes.md`.

## Wayfinder

`/wayfinder` keeps its map and numbered question files as
`~/.claude/docs/agents/wayfinder.md` describes.
