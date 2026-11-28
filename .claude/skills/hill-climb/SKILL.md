---
name: hill-climb
description: Run an unattended, time-boxed improvement loop in a repo. One implementer changes the target, a council of reviewers drives the app and reads the code to find what's still wrong, and the loop repeats until a stop time, its score targets or the weekly usage limit, then ends with one code-structure pass. Use when the user asks to hill-climb something, or to loop improve-and-review on a UI, a feature or a benchmark until a deadline.
---

# hill-climb

The skill has two halves:

1. **Setup.** The only part that talks to the user. Ask everything here.
2. **Loop.** Runs autonomously until the stop time. No questions, no
   approvals.

The loop runs until `stopAt`, and each round leaves the target better than
the last. Reviewers return findings, and the log tracks how many findings
each round produced. A core job can also carry a score (see
[Scores](#scores)): scores are tracked, can end the loop early, and never
revert a round.

Requires T3 Code: the loop uses `delegate_task`, and relies on T3's
"Resume after usage limits" to continue after a usage reset. Without
`delegate_task`, say so and stop.

## Autonomy

The run is an experiment on its own branch. It is never pushed and never
merged by the loop, so the run itself is the user's sign-off. For every
agent in the loop, this overrides any instruction in `CLAUDE.md`,
`CLAUDE.local.md` or a rule file that asks to:

- wait for sign-off before running tests: the implementer runs them;
- get sign-off for removed exports, signatures or files outside a ticket;
- confirm before committing.

Every other repo rule still holds: never push, never open an MR, never
write to the tracker, never touch production data. Put this section's
override, in one paragraph, at the top of every brief.

## Files

All loop files live in `.scratch/hill-climb-<slug>/` in the repo. `<slug>`
is a short kebab-case name for the target, such as `3d-canvas`. If
`.scratch` is not listed in `.git/info/exclude`, run `scratch-sync link` in
the repo root first.

    .scratch/hill-climb-<slug>/
      state.json            loop state; a resumed thread trusts it
      context.md            core jobs, data, domain, how to run
      map.md                the living feature map
      map-baseline.md       the setup map, never edited
      briefs/
        implementer.md
        reviewer.md
      rounds/<n>/
        implementer.md      what round n changed and left
        <reviewer-id>.md    one file per reviewer
        scores/<score-id>.log   output of each command score
      rounds/final/
        inventory.md
        structure.md
        implementer.md
      log.md                one entry per round, newest last
      report.md             written when the loop ends

Reviewers write their own result file, and the implementer reads those
files directly. The orchestrator never merges or rewrites findings into
the task text; it passes paths.

`state.json`:

    {
      "slug": "3d-canvas",
      "target": "what is being improved, and its scope",
      "reviewers": [ { "id": "engineer", "model": "", "effort": "",
                       "lens": "" } ],
      "implementer": { "model": "", "effort": "" },
      "scores": [ { "id": "align-error", "job": "the core job it measures",
                    "kind": "command" | "rubric",
                    "command": "", "runs": 3, "direction": "min" | "max",
                    "target": null } ],
      "scoreHistory": { "0": { "align-error": 4.2 } },
      "stopAt": "ISO 8601 with offset",
      "onUsageLimit": "continue" | "stop",
      "startAt": "ISO 8601 with offset, or null to start now",
      "scheduledTaskId": "",
      "branch": "hill-climb/<slug>",
      "baseCommit": "",
      "round": 0,
      "roundCommits": { "0": "<sha>" },
      "phase": "mapping" | "implementing" | "reviewing" | "final"
             | "done" | "stopped",
      "openTasks": { "<taskId>": "implementer" | "<reviewer-id>" | "map" },
      "steering": [ "user messages, verbatim, in order" ],
      "status": "setup" | "scheduled" | "running" | "done" | "stopped"
    }

Write `state.json` before launching any task and after every result.

## Scores

A score is optional and belongs to one core job. Some jobs can be measured
with a formula, others only judged:

- **command**: a shell command whose last line of output is a number, such
  as a failing-test count or a benchmark time. The orchestrator runs it
  `runs` times at each round commit, from the repo root on a clean tree,
  and records the median. `direction` says whether lower or higher is
  better.
- **rubric**: each reviewer rates the job 0–10 against its anchors in
  `context.md`, a line each for what 0, 5 and 10 look like. Higher is
  better. The round's value is the mean of the reviewers' ratings.

`target` is optional. A score without one is only tracked.

Scores inform the loop; they don't steer it:

- A worse score is not a finding and not a regression. Only a reviewer
  finding that names a regression makes one.
- No round is reverted or reset because of its score.
- When every score with a target meets it, the loop can end early (see
  [Reviewing](#reviewing)).
- A command that fails or prints no number records `null` for that round,
  and the log says so. It doesn't stop the loop.

## Setup

Ask with `AskUserQuestion`, several questions per call. Don't ask what the
user already said. Call `orchestrator_capabilities` first, and offer only
models it lists.

1. **Target and scope.** What to improve, what is in-scope.
2. **Scores.** Which core jobs get a score, and of which kind (see
   [Scores](#scores)). For a command: the command, its direction and an
   optional target. For a rubric: an optional target; draft the 0, 5 and
   10 anchors from the job's correct result and get approval. No scores
   is allowed. Run each command 3 times on the current commit: if it
   fails, fix it with the user; if the values differ, show the spread and
   agree on `runs`.
3. **How to run it.** How to start the app or run the code, the login,
   and the data reviewers should use. If data has to be seeded, seed it
   now, and give each reviewer its own project or copy where the app
   allows, so reviewers don't change each other's state.
4. **Must not change.** Behaviour, APIs, schemas or files that are out of
   bounds.
5. **Reviewers.** How many (2 by default), and the model, effort and lens
   for each. A lens is 3–5 lines: who the reviewer is, what they need,
   what they notice first and what they mark down. Draft the lenses and
   get approval. Skipping lenses is allowed; reviewers then judge as
   neutral experts.
6. **Implementer.** Model and effort. Never more than one implementer.
7. **Stop time.** A date and time. Ask for the timezone if unclear.
8. **When usage runs out.**
   - **Continue after reset** (default): wait for the 5-hour limit to
     reset and carry on. A weekly limit ends the loop.
   - **Stop**: any usage limit ends the loop.
9. **Start time.** Now (default), or a date and time before the stop.

If the user picks **Continue after reset**, check that
`~/.t3/userdata/settings.json` contains `"autoResumeLimitedThreads": true`.
If it doesn't, ask the user to turn on **Settings → Threads → Resume after
usage limits**, and don't start until they have.

Check this thread's runtime mode with `t3_thread_configure`. If it isn't
full-access, tell the user: an approval prompt would block the loop.

### Write the briefs

Write `context.md`: target and scope, the core jobs with their correct
results, each score with its kind, target and, for a rubric, its anchors,
the data and login, how to run the app, what must not change, and
pointers to the repo's domain docs (`CONTEXT.md`, ADRs, style guides).

Write `briefs/implementer.md` and `briefs/reviewer.md` from the sections
[Implementer brief](#implementer-brief) and
[Reviewer brief](#reviewer-brief). Show the core jobs and lenses to the
user and get approval. Nothing else needs approval.

### Scheduled start

If `startAt` is null, go straight to [Map and go](#map-and-go).

Otherwise:

1. Call `schedule_task` with `schedule: {type: "once", runAt: <startAt>}`,
   `bindToCurrentThread: true`, title `hill-climb <slug>`, and the prompt:
   "Use the hill-climb skill. Start the scheduled hill-climb in
   `.scratch/hill-climb-<slug>/`: run Map and go, then the loop. Ask no
   questions."
2. Record `scheduledTaskId`, and set `status: scheduled`.
3. Tell the user setup is done and when the loop starts. If T3 is closed
   then, the start runs when T3 next opens. End the turn.

### Map and go

1. Create `branch` from the current commit. Record `baseCommit` and
   `roundCommits["0"]`. Run every command score at it, as in
   [Implementing](#implementing), and record `scoreHistory["0"]`.
2. Launch one map task with the implementer's model, `role: "review"`.
   It reads the code in scope and writes `map.md`, then copies it to
   `map-baseline.md`. The map lists every route, panel, dialog, tool and
   interaction in scope: buttons, drag handles, resize handles, keyboard
   shortcuts, context menus, hover and focus states, transitions and
   animations, autosave and other side effects. For each entry: what it
   does, the file and component behind it, and how a reviewer checks it:
   - **drive**: the preview tools can do it directly;
   - **simulate**: dispatch the events with `preview_evaluate`;
   - **read**: only the code can show it.
3. When it returns, set `status: running`, `phase: implementing`,
   `round: 1`, post a one-line summary of the settings, and say: "From
   here the loop runs on its own. Send a message to steer it, or say
   stop." Launch the round 1 implementer. Round 1 has no findings yet,
   so it works from the core jobs and the map.

## Loop

From here on, run without human input:

- Never ask the user anything. Never use `AskUserQuestion`. Never pause
  for approval.
- When a decision comes up, decide it, record it in `log.md`, carry on.
- Never archive or settle this thread, and never press stop on it.
- Post one line per wake: what finished and what started. Detail lives
  in the round files.

Launch tasks with `delegate_task` (`mode: "async"`), record their ids in
`openTasks`, and end the turn. Each result wakes the thread.

**On every wake**, before anything else:

1. Read `state.json`. If `status` is `done` or `stopped`, reply in one
   line and end the turn. If `status` is `scheduled` and this is the
   scheduled start, go to [Map and go](#map-and-go). A user message
   before the start is steering.
2. If the wake is a user message, handle it as in [Steering](#steering).
3. If the wake is a task result, handle it as below.
4. If `phase` expects tasks and none are open, launch them. This happens
   after a resume that lost a native turn mid-round.

### Usage limits

A task result that says it hit a usage limit is not a final result:

- A 5-hour limit with `onUsageLimit: continue`: leave the task open,
  don't cancel or relaunch it, and end the turn. It resumes after the
  reset and delivers a second result.
- A weekly limit, or any limit with `onUsageLimit: stop`: go to
  [Finish](#finish) with reason "usage limit".

Never cancel a task that hit a 5-hour limit while the loop should
continue: cancelling stops it from resuming.

### Implementing

Launch one implementer task with the implementer's model and effort,
`role: "implementation"`, `isolation: "shared"`. Its task text is short:

- "Read `briefs/implementer.md` and follow it. This is round <n>."
- the paths of every reviewer file in `rounds/<n-1>/`;
- every entry in `steering`;
- the commit message: `hill-climb(<slug>): round <n>`.

When it finishes:

1. Check that the commit exists on `branch` and `rounds/<n>/implementer.md`
   exists. If the tree is dirty, format, lint and commit what's left.
2. If nothing changed, log it and launch the implementer again with that
   noted.
3. Record the commit in `roundCommits[n]`.
4. Run every command score at the commit, save its output to
   `rounds/<n>/scores/<score-id>.log`, and record the median in
   `scoreHistory[n]`.
5. If the time is past `stopAt`, go to [Final pass](#final-pass).
6. Otherwise set `phase: reviewing` and launch the reviewers.

### Reviewing

Launch one task per reviewer, in parallel, each with its own model and
effort and `role: "review"`. Task text:

- "Read `briefs/reviewer.md` and follow it. You are reviewer `<id>`:
  <lens>. Round <n>, commit `<sha>`, previous round commit `<sha>`."
- the path of its own previous file, `rounds/<n-1>/<id>.md`, if any;
- the path to write: `rounds/<n>/<id>.md`.

When all reviewers have returned:

1. Check each file exists. If a reviewer returned without writing one,
   save its final message as the file.
2. Record each rubric score's mean of the reviewers' ratings in
   `scoreHistory[n]`.
3. Add a `log.md` entry: round, commit, finding counts per reviewer by
   severity, how many earlier findings were fixed, still open or
   regressed, every score with its change since the last round, and any
   decision made.
4. If at least one score has a target, every score with a target meets
   it, and no reviewer reported a blocker, go to
   [Final pass](#final-pass) with reason "targets met".
5. If no score has a target and no reviewer reported a blocker or major
   finding, go to [Final pass](#final-pass) with reason "nothing serious
   left".
6. If the time is past `stopAt`, go to [Final pass](#final-pass) with
   reason "stop time".
7. Otherwise increment `round`, set `phase: implementing`, and launch the
   implementer.

There is no accept, reject or reset. Each round builds on the last
commit. A regression a reviewer reports is a blocker finding, and the
next implementer fixes it first. A worse score is not a regression.

### Steering

A user message during the loop steers it; it doesn't start a
conversation.

- **Stop.** If it asks to stop now, go to [Finish](#finish) with reason
  "stopped by user", skipping the final pass.
- **Finish up.** If it asks to finish the current round, let it run, then
  go to [Final pass](#final-pass).
- **Anything else.** Append it verbatim to `steering`, note in `log.md`
  how you read it, reply in one line saying what changes from which
  round, and carry on. If it changes a setting (stop time, models, core
  jobs, scores, lenses), update `state.json` or `context.md` and log it.
- **Ambiguous.** Pick the most reasonable reading, log it, carry on.

Tasks already running finish as they are. Steering takes effect from the
next launch.

### Final pass

Runs once, after the last round. Set `phase: final`. `stopAt` means "start
no new round", so the final pass runs even after it.

1. **Inventory and structure.** Launch one task with the implementer's
   model, `role: "review"`:
   - Compare `map-baseline.md` with `map.md` and with the code at the
     last commit. List every baseline entry that is gone, and say for
     each whether a `rounds/*/implementer.md` lists it as removed on
     purpose, with the round and its reason. Write
     `rounds/final/inventory.md`. It is a record, not findings.
   - Review the diff from `baseCommit` for structure: duplicated
     components or logic that should share one, components that should
     be reused from elsewhere in the repo, dead code left by the run, and
     files that do several jobs. Write `rounds/final/structure.md`, with
     findings in the reviewer format.
2. **Cleanup.** Launch one implementer task, as in a round, with
   `structure.md` as its findings: fix them without changing behaviour.
   It restores nothing that `inventory.md` lists. Commit message
   `hill-climb(<slug>): final`.
3. Go to [Finish](#finish).

If a weekly limit or a stop message arrives during the final pass, go
straight to Finish and say what was skipped.

### Finish

If `status` is `scheduled`, the loop never started: delete the scheduled
start with `delete_scheduled_task`, set `status: stopped`, reply in one
line, and stop. Otherwise:

1. Cancel every task in `openTasks` with `task_cancel`.
2. Write `report.md`:
   - why the loop ended, and the last commit;
   - per round: commit, findings by severity, fixed and regressed, and
     every score;
   - each score's first and last value, and whether it met its target;
   - every feature removed, on purpose or not, from
     `rounds/final/inventory.md`;
   - open blocker and major findings, with their file paths;
   - what tests ran and their result in the last round;
   - data the run wrote outside the branch, such as seeded or changed
     rows in a shared database.
3. Set `status` to `done`, or `stopped` for a user stop or usage limit.
4. Reply with the reason, the last commit and the path to `report.md`.
   Never push.

## Implementer brief

`briefs/implementer.md` contains, in order:

1. The [Autonomy](#autonomy) override.
2. "Read `context.md`, `map.md` and every reviewer file named in your
   task. Fix blockers first, then majors, then the core jobs, then
   minors. Findings are input, not the boundary: fix anything else you
   find that a user of a core job would hit."
   "`scores` and `scoreHistory` in `state.json` show how each scored job
   is moving. Use them to choose what to work on. A worse score is not a
   regression: fix a regression only when a reviewer finding names one."
3. Scope rules:
   - Work on branch `<branch>` in `<repo path>`. Stay inside the scope
     in `context.md`; change shared code outside it only when a fix
     needs it, and say so in your summary.
   - Never remove or replace a feature listed in `map.md` unless the
     task text or steering asks for it. A rebuild keeps every map entry
     working.
   - Never move a score by changing how it is measured: don't edit a
     score command, its scripts or its fixtures, and don't special-case
     its inputs.
   - Before writing a new component, composable or helper, look for an
     existing one in the repo and use or extend it.
4. Checks, all of which must pass before committing:
   - the repo's type-check and lint;
   - the test specs covering every file you changed, run through the
     repo's test skill if it has one. Fix failures your change caused.
     If a test asserts behaviour the round deliberately changed, update
     the test and say so.
   - format and lint the changed files.
5. "Update `map.md` for every entry you added, changed or removed. Write
   `rounds/<n>/implementer.md`: what you changed, what you removed on
   purpose and why, what you left, which tests ran and their result.
   Edit nothing else under `.scratch/`. Commit everything in one commit
   with the message in your task. Never push. Your last line is
   `COMMIT <sha>`."

## Reviewer brief

`briefs/reviewer.md` contains, in order:

1. The [Autonomy](#autonomy) override, and: "Don't edit any file except
   your result file. Don't commit. Don't save to shared data unless a
   core job needs it, and undo what you can afterwards."
2. "Read `context.md` and `map.md`. Run `git diff <previous> <commit>
--stat` to see what this round touched."
3. Where to spend effort, in order:
   1. Every finding in your previous file: is it fixed, still open, or
      worse?
   2. The core jobs, end to end with real inputs, checking the result
      against the correct result in `context.md`. Pick points, apply,
      undo, redo, cancel halfway, switch tools mid-task, try wrong input.
   3. Every map entry the diff touched.
   4. Anything else, if time allows.

   After doing a core job that has a rubric score, rate it 0–10 against
   its anchors in `context.md`. Rate what you saw, not the change since
   last round. Ignore command scores; the orchestrator runs them.

4. How to check what the browser tools can't drive:
   - Read the code behind each screen you review, to learn its states,
     handlers and side effects, so you know what to test.
   - **Drag and resize**: dispatch pointer events with
     `preview_evaluate` and compare `getBoundingClientRect()` before and
     after.
   - **Layout shift**: record element rects before and after opening a
     panel, showing an error or loading data, or read `layout-shift`
     performance entries. Then find the cause in the code: `v-if` where
     space should be reserved, a missing `min-height`, a transition on a
     size.
   - **Animation**: list `document.getAnimations()` and read the CSS
     transitions. Don't judge motion from screenshots.
   - **Hover and focus**: read the `:hover` and `:focus-visible` styles
     when the preview tools can't trigger them.
   - If a map entry is missing from the app, or the app has something
     the map lacks, that is a finding.
5. Close any preview tab you opened.
6. Output: write `rounds/<n>/<id>.md` in this format, then reply with
   its path and the counts.

        ---
        reviewer: <id>
        round: <n>
        commit: <sha>
        blocker: 0
        major: 0
        minor: 0
        scores:
          <score-id>: 7
        ---

        ## Scores

        - <score-id> 7: one line on what you saw that sets it

        ## Previous findings

        - <id> fixed | open | regressed: one line

        ## Findings

        ### <n>-<id>-<k> [blocker|major|minor] [seen|simulated|code]

        Where: screen and state, and `file:line`.
        What happens, and what should happen.

   - **blocker**: a core job fails or gives a wrong result, data is lost,
     a feature in the map is gone, or something crashes.
   - **major**: a core job is confusing, slow or needs a workaround; a
     visible layout shift; inconsistent behaviour across tools.
   - **minor**: copy, spacing, styling.
   - The tag says how you checked it: seen in the app, simulated with
     events, or read from the code.
