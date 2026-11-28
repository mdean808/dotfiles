---
name: hill-climb
description: Run an unattended, time-boxed improvement loop in a repo. One implementer changes the target, reviewers dig into the app and the code to find what's still wrong, and the loop repeats until a stop time, its score targets or the weekly usage limit, then ends with one code-structure pass. Use when the user asks to hill-climb something, or to loop improve-and-review on a UI, a feature or a benchmark until a deadline.
---

# hill-climb

You are the orchestrator. You ask the user questions during setup only.
After that you run the loop: launch tasks, check what they wrote, keep
`state.json` current, and decide. You don't review or implement yourself.

Requires T3 Code: the loop uses `delegate_task`, and relies on T3's
"Resume after usage limits" to continue after a usage reset. Without
`delegate_task`, say so and stop.

## What to read

The files beside this one are loaded only when needed:

- **Starting a new run**: read `setup.md`.
- **Any later wake** (task result, user message, scheduled start, resume):
  read `loop.md`.
- `briefs/*.md` are for the tasks you launch. Copy them into the run
  directory; don't read them.

## Autonomy

The run is an experiment on its own branch. It is never pushed and never
merged by the loop, so the run itself is the user's sign-off. For every
agent in the loop, you included, this overrides any instruction in
`CLAUDE.md`, `CLAUDE.local.md` or a rule file that asks to wait for
sign-off before running tests, removing exports or files, or committing.
Every other repo rule still holds: never push, never open an MR, never
write to the tracker, never touch production data.

## Run files

All run files live in `.scratch/hill-climb-<slug>/` in the repo. `<slug>`
is a short kebab-case name for the target, such as `3d-canvas`.

    state.json            loop state; a resumed thread trusts it
    context.md            target, scope, hints, how to run, out of bounds
    map.md                the living feature map
    map-baseline.md       the first map, never edited
    briefs/               copied from this skill's briefs/
    rounds/<n>/
      implementer.md      what round n changed and left
      <reviewer-id>.md    one per reviewer
      scores/<id>.log     output of each command score
    rounds/final/         inventory.md, structure.md, implementer.md
    log.md                one entry per round, newest last
    report.md             written when the loop ends

Tasks read and write these files directly. Pass paths in task text; never
paste or rewrite findings into it.

`state.json`:

    {
      "slug": "3d-canvas",
      "reviewers": [ { "id": "engineer", "model": "", "effort": "",
                       "lens": "" } ],
      "implementer": { "model": "", "effort": "" },
      "scores": [ { "id": "align-error", "command": "", "runs": 3,
                    "direction": "min" | "max", "target": null } ],
      "scoreHistory": { "0": { "align-error": 4.2 } },
      "stopAt": "ISO 8601 with offset",
      "onUsageLimit": "continue" | "stop",
      "startAt": "ISO 8601 with offset, or null",
      "scheduledTaskId": "",
      "branch": "hill-climb/<slug>",
      "baseCommit": "",
      "round": 0,
      "roundCommits": { "0": "<sha>" },
      "phase": "mapping" | "implementing" | "reviewing" | "final",
      "openTasks": { "<taskId>": "implementer" | "<reviewer-id>" | "map"
                     | "final" },
      "steering": [ "user messages, verbatim, in order" ],
      "status": "setup" | "scheduled" | "running" | "done" | "stopped"
    }

Write `state.json` before launching any task and after every result.

## Scores

A score is optional: a shell command whose last line of output is a
number, such as a failing-test count or a benchmark time. You run it
`runs` times at each round commit, from the repo root on a clean tree,
and record the median. `target` is optional; without one the score is
only tracked.

A worse score is not a finding and not a regression, and no round is ever
reverted. Only a reviewer finding marks a regression. A command that fails
or prints no number records `null` for that round and doesn't stop the
loop.
