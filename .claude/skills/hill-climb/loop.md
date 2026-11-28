# Loop

Runs with no human input. Never ask the user anything, never pause for
approval, and never archive, settle or stop this thread. When a decision
comes up, make it, note it in `log.md` and carry on. Post one line per
wake: what finished and what started.

Launch every task with `delegate_task` (`mode: "async"`), record its id
in `openTasks`, and end the turn. Each result wakes the thread. Start
every task text with the run directory's absolute path; the paths below
are relative to it.

## On every wake

1. Read `state.json`.
   - `done` or `stopped`: reply in one line and end the turn.
   - `scheduled` and this is the scheduled start: run Map and go from
     `setup.md`.
2. A user message: see [Steering](#steering).
3. A task result: remove it from `openTasks`. If it hit a usage limit,
   see [Usage limits](#usage-limits). Otherwise handle it by phase below.
4. If the phase expects open tasks and none are open, launch them. This
   happens after a resume lost a turn mid-round.

## Implementing

Launch one task with the implementer's model and effort,
`role: "implementation"`, `isolation: "shared"`:

- "Read `briefs/implementer.md` and follow it. Round <n>."
- the paths of every reviewer file in `rounds/<n-1>/`;
- every entry in `steering`;
- commit message `hill-climb(<slug>): round <n>`.

When it returns:

1. Check the commit is on `branch` and `rounds/<n>/implementer.md`
   exists. If the tree is dirty, format, lint and commit what's left.
   If nothing changed, log it and launch the implementer again with
   that noted.
2. Record `roundCommits[n]`. Run every score, save the output to
   `rounds/<n>/scores/<id>.log`, and record the median in
   `scoreHistory[n]`.
3. If every score with a target now meets it, go to
   [Final pass](#final-pass) with reason "targets met".
4. If it's past `stopAt`, go to [Final pass](#final-pass) with reason
   "stop time".
5. Set `phase: reviewing` and launch the reviewers.

## Reviewing

Launch one task per reviewer, in parallel, each with its own model and
effort and `role: "review"`:

- "Read `briefs/reviewer.md` and follow it. You are reviewer `<id>`:
  <lens>. Round <n>, commit `<sha>`, previous commit `<sha>`."
- its previous file, `rounds/<n-1>/<id>.md`, if any;
- the path to write: `rounds/<n>/<id>.md`.

When all have returned:

1. Check each file exists. If one is missing, save that reviewer's
   final message as its file.
2. Read the files. If one has no `## Dug into` section, or only lists
   findings without what was tried, relaunch that reviewer once with:
   "Your review stayed on the surface. Follow `briefs/reviewer.md`
   section Depth." Log it.
3. Add a `log.md` entry: round, commit, findings per reviewer by
   severity, earlier findings fixed, open or regressed, scores and their
   change since the last round, what each reviewer dug into, and any
   decision you made.
4. If it's past `stopAt`, go to [Final pass](#final-pass) with reason
   "stop time".
5. Increment `round`, set `phase: implementing`, and launch the
   implementer.

A round with no findings doesn't end the loop: the next implementer
works from the map, the hints and the scores, and the reviewers dig
somewhere new.

## Usage limits

A result that says it hit a usage limit is not a final result.

- 5-hour limit with `onUsageLimit: continue`: leave the task open and end
  the turn. It resumes after the reset and returns again. Never cancel
  it; cancelling stops the resume.
- Weekly limit, or any limit with `onUsageLimit: stop`: go to
  [Finish](#finish) with reason "usage limit".

## Steering

A user message during the loop steers it.

- **Stop now**: go to [Finish](#finish) with reason "stopped by user".
- **Finish up**: let the current round finish, then go to
  [Final pass](#final-pass).
- **Anything else**: append it verbatim to `steering`, note in `log.md`
  how you read it, reply in one line saying what changes from which
  round, and carry on. If it changes a setting (stop time, models,
  scores, hints, lenses), update `state.json` or `context.md` and log
  it. If it's ambiguous, take the most reasonable reading and log it.

Running tasks finish as they are; steering applies from the next launch.

## Final pass

Runs once, even after `stopAt`. Set `phase: final`.

1. Launch one task with the implementer's model, `role: "review"`:
   "Read `briefs/final.md` and follow it."
2. When it returns, launch the implementer as in a round, with
   `rounds/final/structure.md` as its findings and this added: "Fix these
   without changing behaviour. Restore nothing `inventory.md` lists."
   Commit message `hill-climb(<slug>): final`.
3. Go to [Finish](#finish).

A weekly limit or a stop message during the final pass goes straight to
Finish; say what was skipped.

## Finish

If `status` is `scheduled`, the loop never started: delete the start
with `delete_scheduled_task`, set `status: stopped`, reply in one line,
and stop. Otherwise:

1. Cancel every task in `openTasks` with `task_cancel`.
2. Write `report.md`:
   - why the loop ended, and the last commit;
   - per round: commit, findings by severity, fixed, regressed, scores;
   - each score's first and last value, and whether it met its target;
   - every feature removed, on purpose or not, from `inventory.md`;
   - open blocker and major findings, with their file paths;
   - tests run in the last round and their result;
   - data the run wrote outside the branch, such as seeded rows.
3. Set `status: done`, or `stopped` for a user stop or usage limit.
4. Reply with the reason, the last commit and the path to `report.md`.
   Never push.
