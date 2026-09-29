# Personal agent files in a shared repo

Applies to every repo on this machine. Skills that generate durable markdown
(domain models, ADRs, glossaries, research notes, specs, tickets, triage briefs,
change notes, scratch work) must write it to a personal path, not a conventional
one.

## Where personal files go

| Purpose | Path |
| --- | --- |
| Instructions for Claude, this repo only | `CLAUDE.local.md` at the repo root |
| Domain model, ADRs, agent docs, anything durable | `.local/` |
| Per-feature working notes: specs, tickets, briefs, change notes | `.scratch/<feature>/` |

A skill that wants `CONTEXT.md` writes `.local/CONTEXT.md`. One that wants
`docs/adr/` writes `.local/docs/adr/`. One that asks where the repo keeps notes
and finds no convention uses `.scratch/<feature>/`. Keep the skill's own internal
layout underneath; only the root changes.

## Why these names

A repo tracks `CLAUDE.md`, `docs/` and `CONTEXT.md` sooner or later. Once it
tracks a path, checkout writes that path unconditionally and a personal file
sitting there is destroyed with no warning, no conflict and no reflog entry.
gitignore does not enter into it: it governs untracked files only. The protection
is the name, and `CLAUDE.local.md`, `.local/` and `.scratch/` are names no
upstream branch takes.

This already happened once: a rebase that checked out a branch carrying a
committed `CLAUDE.md` silently replaced a personal one.

## Setting up a repo

Add to `.git/info/exclude`, never to the repo's `.gitignore` and never to the
global excludes file:

```
CLAUDE.local.md
.local/
.scratch/
.claude/settings.local.json
```

`.git/info/exclude` is per-repo, is not committed, and no upstream change can
alter it. A global excludes file makes one repo's choice apply to every other
repo, which is how the collision above went unnoticed.

## Rules

- Never create a bare `CLAUDE.md`, `CONTEXT.md` or `docs/` at a repo root for
  personal use. Redirect to the table above and say so in one line.
- Never move personal content into a tracked path to make it visible to a
  teammate. Copy it into the PR description, a ticket, or a file the team owns.
- `CLAUDE.local.md` loads after the repo's `CLAUDE.md` and wins on conflicts.
  Put personal preferences there, not in the shared file.
- `CLAUDE.local.md` is per-worktree. To share personal instructions across
  worktrees of one repo, import from the home directory instead:
  `@~/.claude/<repo>-instructions.md`.
- Before writing durable markdown, check whether a personal path already holds
  the file under its conventional name and use that one.
- These paths are only for docs the repo does not track. If the repo tracks the
  doc (for example a committed `CONTEXT.md` or `docs/adr/`), edit it where it
  is.
