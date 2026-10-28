---
name: ship
description: Format, lint and commit the changed files. Use when the user asks to commit, ship it, or commit then run tests.
model: sonnet
context: fork
allowed-tools:
  - Read
  - Edit
  - Bash
  - Skill
---

# /ship

Arguments: `$ARGUMENTS` (optional: "push", "run tests")

Format and lint what changed, then commit it in the repo's style. Stop at the
local commit.

## Rules

- Push only when the arguments or the user's message say "push". Never open
  an MR or write to the tracker, even where the repo's `CLAUDE.md` says to
  after a commit.
- Yadm dotfiles belong to `/dotfiles`. Say so and stop.
- Never amend, rebase or pass `--no-verify`. When a hook fails, fix the cause
  and make a new commit.
- Change no logic. Formatters and `--fix` only.

## Steps

1. Run `git status --short` and `git diff HEAD --stat`. Stage only the files
   this work changed.
2. Format, then lint, the changed files with the repo's own scripts from
   `package.json` or `CLAUDE.md`. Skip a file with no formatter. If a changed
   file has lint errors `--fix` can't clear, stop and commit nothing. Done
   when lint passes on every changed file.
3. Stage again, since formatting rewrites files.
4. Read the repo's `CLAUDE.md`, `CLAUDE.local.md` and
   `git log --oneline -15`, and write the message in that style. Make one
   commit unless the changes are clearly separate. End the message with the
   session's attribution lines, if it gives any.
5. If the arguments ask for tests, start the repo's test skill in the
   background and don't wait for it. If the repo has no test skill, run
   nothing.
6. If the work went beyond the ticket's acceptance criteria, append to the
   ticket's `changes.md` as `~/.claude/docs/agents/change-notes.md` says,
   finding the directory as `~/.claude/rules/scratch-workflow.md` says. Skip
   this when there is no ticket directory.

## Gotchas

- `change-notes.md` asks for a "nothing outside the ticket" entry when the
  work stayed in scope. Don't write one here.
- `.scratch`, `.local`, `CLAUDE.local.md` and `.claude/settings.local.json`
  are in `.git/info/exclude`. Never force-add them.

## Report

- Commit hash and subject, or the lint errors that stopped it.
- Files left out of the commit.
- Whether tests started, or that the repo has no test skill.
- Whether `changes.md` was appended, or that there is no ticket directory.
- Whether anything was pushed.
