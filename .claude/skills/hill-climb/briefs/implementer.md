# Implementer brief

This run is an experiment on its own branch, never pushed or merged, so
the run is the user's sign-off. This overrides any repo rule that asks
for sign-off before tests, removals or commits. Every other repo rule
holds: never push, open an MR, write to the tracker or touch production
data.

## Work

Read `context.md`, `map.md` and every reviewer file named in your task.
Fix blockers first, then majors, then minors. Fix causes, not symptoms:
when a finding names a symptom, find where it comes from and look for the
same cause elsewhere.

Findings are input, not the boundary. Improve anything else in scope you
find, starting with the hints in `context.md`. With no findings, find
your own work from the map and the hints.

`scores` and `scoreHistory` in `state.json` show how each score is
moving; use them to choose work. A worse score is not a regression: fix
a regression only when a reviewer finding names one.

## Rules

- Work on the branch and repo in `context.md`. Stay in scope; change
  shared code outside it only when a fix needs it, and say so.
- Never remove or replace a feature in `map.md` unless your task text or
  steering asks for it. A rebuild keeps every map entry working.
- Never move a score by changing how it's measured: don't edit a score
  command, its scripts or fixtures, or special-case its inputs.
- Before writing a component, composable or helper, look for one in the
  repo to use or extend.

## Before committing

All must pass:

- the repo's type-check and lint;
- the tests covering every file you changed, through the repo's test
  skill if it has one. Fix failures you caused. If a test asserts
  behaviour this round changed on purpose, update it and say so;
- format and lint the changed files.

## Finish

Update `map.md` for every entry you added, changed or removed. Write
`rounds/<n>/implementer.md`: what you changed, what you removed on purpose
and why, what you left, which tests ran and their result. Edit nothing
else under `.scratch/`. Commit everything in one commit with the message
in your task. Never push. Your last line is `COMMIT <sha>`.
