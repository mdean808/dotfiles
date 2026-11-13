---
name: hill-climb
description: Run an unattended hill-climb in a repo. Graders score a target (UI, code organisation, DB, lookups, a benchmark), one implementer improves it, and the loop repeats until every grader reaches the goal score or a hard stop date passes. Use when the user asks to hill-climb something, or to loop improve-and-score until a score is reached.
---

# hill-climb

The skill has two halves:

1. **Setup.** The only part that talks to the user. Ask everything here.
2. **Loop.** Runs autonomously until done. No questions, no approvals.

Requires T3 Code: the loop uses `delegate_task`, and relies on T3's
"Resume after usage limits" to continue after a usage reset. Without
`delegate_task`, say so and stop.

## State

All state lives in `.scratch/hill-climb-<slug>/` in the repo the skill runs
in. `<slug>` is a short kebab-case name for the target, such as
`settings-ui` or `search-latency`. If `.scratch` is not listed in
`.git/info/exclude`, run `scratch-sync link` in the repo root first.

    .scratch/hill-climb-<slug>/
      state.json      source of truth for the loop
      rubric.md       rubric targets only
      bench/          benchmark targets only: harness and baseline results
      log.md          one entry per round, newest last
      rounds/<n>.md   grader reports and implementer summary for round n
      report.md       written when the loop ends

`state.json`:

    {
      "slug": "settings-ui",
      "target": "what is being improved, and its scope",
      "kind": "rubric" | "benchmark",
      "metric": { "name": "", "unit": "", "direction": "higher" | "lower",
                  "noise": 0 },
      "goal": 9.5,
      "graders": [ { "id": "g1", "model": "", "effort": "",
                     "persona": "" } ],
      "implementer": { "model": "", "effort": "" },
      "howToRun": "commands to start the app or run the benchmark",
      "inspect": "screens, paths, queries or commands graders look at",
      "guardrails": "what must not change, and the checks that must pass",
      "stopAt": "ISO 8601 with offset",
      "onUsageLimit": "continue" | "stop",
      "branch": "hill-climb/<slug>",
      "baseCommit": "",
      "best": { "round": 0, "commit": "", "scores": {}, "benchmark": null },
      "round": 0,
      "phase": "setup" | "implementing" | "grading" | "done" | "stopped",
      "openTasks": { "<taskId>": "implementer" | "g1" },
      "steering": [ "user steering messages, verbatim, in order" ],
      "status": "setup" | "running" | "done" | "stopped"
    }

Write `state.json` before launching any task and after every result. A
resumed thread trusts the file, not its memory.

## Setup

Ask with `AskUserQuestion`, several questions per call. Don't ask what the
user already said. Call `orchestrator_capabilities` first, and offer only
models it lists as options.

1. **Target.** What to improve: UI, code organisation, DB schema or
   queries, lookup speed, a benchmark, or other. Then the scope: which
   screens, paths, queries or operations.
2. **How to run it.** How to start the app or run the code, and what graders
   should inspect.
3. **Guardrails.** What must not change, and which checks must keep passing
   (tests, typecheck, lint).
4. **Goal score.** On a 0–10 rubric the default is 9.5. For a benchmark,
   the target value of the metric.
5. **Graders.** How many, and which model and effort level for each.
   - For a benchmark, the benchmark sets the score. Graders act as reviewers:
     each passes or fails the change for correctness and for gaming the
     benchmark, and gives feedback. Zero graders is allowed.
6. **Grader personas.** Who each grader judges as, so their opinions differ,
   such as a developer, a tunnelling manager, a mining engineer or a
   company owner. Each grader gets a different persona.
   - For each label, draft a persona of 3–5 lines: the role, what they need
     from the target, what they notice first, and what makes them mark it
     down. Show the drafts and get approval.
   - Skipping personas is allowed. Graders then judge as neutral experts.
7. **Implementer.** Which model and effort level. There is always exactly
   one implementer.
8. **Hard stop.** A date and time. The loop stops then even if the goal
   isn't met. Ask for the timezone if it's unclear.
9. **When usage runs out.**
   - **Continue after reset** (default): wait for the limit to reset, then
     carry on.
   - **Stop**: end the loop and write the report.

If the user picks **Continue after reset**, check that
`~/.t3/userdata/settings.json` contains `"autoResumeLimitedThreads": true`.
If it doesn't, ask the user to turn on **Settings → Threads → Resume after
usage limits**, and don't start until they have.

Check this thread's runtime mode with `t3_thread_configure`. If it isn't
full-access, tell the user: an approval prompt would block the loop and
stop auto-resume.

### Build the measure

**Rubric targets** (UI, code organisation, anything subjective). Write
`rubric.md`:

- 4–8 criteria that sum to 10 points, each with what a full score, a half
  score and zero look like. Use concrete, checkable anchors, such as "every
  interactive element has hover, focus and disabled states". Never write
  "looks good".
- For UI, list the exact screens, viewport sizes and states to check, so
  every round inspects the same things.

**Benchmark targets** (speed, DB, lookups, throughput, anything measurable).
Build the benchmark before anything else:

- Put the harness in `bench/`, outside git, so the implementer can't change
  it.
- Run warm-up iterations, then enough measured runs to report a median and
  a spread.
- Include a correctness check against a reference output. A run that fails
  it scores as a failure, however fast it is.
- Run the whole harness at least 5 times on the base commit. Record the
  baseline median and the noise, as the spread across those runs, in
  `metric.noise`.
- If the noise is too large to tell a real improvement from a fluke, fix the
  harness (more runs, fixed seeds, isolated data) and measure again.

Show the rubric or benchmark to the user and get approval.

### Baseline and go

1. Create `branch` from the current commit, and record `baseCommit`.
2. Grade the base commit as round 0, the same way as any round. Record it
   as `best`.
3. Show the user the round-0 scores and a summary of every setting, and
   say: "From here the loop runs on its own. Send a message to steer it, or
   say stop."
4. Set `status: running`, `phase: implementing`, `round: 1`, and start the
   loop. Do not wait for a reply.

## Loop

From here on, run without human input:

- Never ask the user anything. Never use `AskUserQuestion`. Never pause for
  approval or confirmation.
- When a decision comes up, decide it from `state.json`, record it in
  `log.md`, and carry on.
- Never archive or settle this thread, and never press stop on it.

The loop is driven by task results. Launch tasks with `delegate_task`
(`mode: "async"`), record their ids in `openTasks`, and end the turn. Each
result wakes the thread.

**On every wake**, before anything else:

1. Read `state.json`. If `status` is `done` or `stopped`, reply in one line
   and end the turn.
2. Check the time with `date`. If it is past `stopAt`, go to
   [Finish](#finish) with reason "hard stop".
3. If the wake is a user message, handle it as described in
   [Steering](#steering).
4. If the wake is a task result, handle it as described below.
5. If `phase` expects tasks and none are open, launch them. This happens
   after a resume that lost a native turn mid-round.

### Usage-limit results

A task result whose text says it hit a usage limit is not a final result:

- With `onUsageLimit: continue`, leave the task open, don't cancel or
  relaunch it, and end the turn. The task resumes after the reset and
  delivers a second result.
- With `onUsageLimit: stop`, go to [Finish](#finish) with reason "usage
  limit".

Never cancel a task that hit the limit while the loop should continue,
because cancelling stops it from resuming.

### Implementing

Launch one implementer task with the implementer's model and effort,
`role: "implementation"`, and `isolation: "shared"`. Its task text:

- the target, scope, guardrails and how to run it;
- the feedback from the graders of the `best` round, with duplicates merged;
- what earlier rejected rounds tried, so it doesn't repeat them;
- every entry in `steering`;
- "Work on branch `<branch>`. Make the changes that most raise the score.
  Run the guardrail checks. Format and lint the changed files. Then commit
  all your work in one commit with message `hill-climb(<slug>): round <n>`.
  Never push. Never edit anything under `.scratch/`. Your last line is
  `COMMIT <sha>`."

When it finishes:

1. Check that the commit exists on `branch`. If the tree is dirty, format,
   lint and commit what's left yourself.
2. If nothing changed, log it and launch the implementer again with that
   noted.
3. Record the commit, and set `phase: grading`.

### Grading

**Rubric targets.** Launch one task per grader, in parallel, each with its
own model and effort, and `role: "review"`. Each grader gets:

- its persona as the first lines of the task text: "You are <persona>.
  Judge everything as this person would." The persona shapes what the
  grader notices, how strictly it applies each criterion, and its feedback.
  The rubric still sets the score;
- `rubric.md`, `inspect`, and how to run the app;
- for UI, the instruction to open and screenshot every listed screen and
  state with the preview tools, and to score what renders, not the code;
- no earlier scores and no implementer notes;
- the output format: a score per criterion, a total out of 10, and the top
  fixes ranked by points gained, each naming the file or screen.

**Benchmark targets.**

1. Run the harness yourself on the round's commit.
2. If the correctness check fails, the round is rejected.
3. Launch the reviewer graders, if any, each with its persona first, the
   diff since `best.commit` and the benchmark result. Each returns PASS or
   FAIL with reasons, plus feedback.

Write every report to `rounds/<n>.md`.

### Decide

**Rubric.** Compare this round with `best`:

- **Reject** if any grader that scored at or above the goal in `best` is now
  below the goal.
- Otherwise, **accept** if the lowest grader score went up, or stayed the
  same while the mean went up.
- Otherwise, **reject**.

**Benchmark.**

- **Accept** if correctness passed, every reviewer passed, and the median
  beats `best` by more than `metric.noise` in `direction`.
- Otherwise, **reject**.

On accept, set `best` to this round.

On reject:

1. Tag the round's commit `hill-climb/<slug>/round-<n>`.
2. Run `git reset --hard <best.commit>` on `branch`.
3. Record why the round was rejected, for the next implementer.

**Done** when `best` has every grader at or above the goal (for a
benchmark: the median meets the goal and every reviewer passes). Go to
[Finish](#finish) with reason "goal reached".

Otherwise, add an entry to `log.md`: round, commit, scores, accepted or
rejected, and why. Then increment `round`, set `phase: implementing`, and
launch the implementer.

### Steering

A user message during the loop steers it. It doesn't start a conversation.

- **Stop.** If the message asks to stop, pause or end, go to
  [Finish](#finish) with reason "stopped by user".
- **Anything else.**
  1. Append the message verbatim to `steering`.
  2. Note in `log.md` how you read it.
  3. Reply in one line saying what changes and from which round.
  4. Carry on.
- **Changing a setting.** If the message changes a setting (the goal, the
  stop date, models, the rubric), update `state.json` and log the change.
- **Ambiguous.** If the message is unclear, pick the most reasonable
  reading, log it, and continue. Don't ask.

Tasks already running finish as they are. Steering takes effect from the
next launch.

### Finish

1. Cancel every task in `openTasks` with `task_cancel`.
2. Run `git reset --hard <best.commit>` on `branch`, so the branch ends on
   the best result.
3. Write `report.md`:
   - the reason the loop ended and the best scores against the goal, first;
   - then the best commit, the rounds run, the score of each round, and the
     strongest remaining feedback.
4. Set `status` to `done`, or to `stopped` for any reason other than
   "goal reached". Set `phase` to match.
5. Reply with the reason, the best scores and the path to `report.md`.
   Never push.
