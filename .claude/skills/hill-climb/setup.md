# Setup

The only part of the run that talks to the user.

## Ask

Call `orchestrator_capabilities` first and offer only the models it
lists. Ask with `AskUserQuestion`, several questions per call. Skip
anything the user already said.

1. **Target and scope.** What to improve, and what is in scope.
2. **Hints.** Optional: jobs, flows or areas the user cares about most.
   Reviewers start there but aren't limited to them. Don't draft hints
   the user didn't give.
3. **Scores.** Optional command scores, each with a direction and an
   optional target. Run each command 3 times on the current commit. If
   it fails, fix it with the user. If the values differ, show the spread
   and agree on `runs`.
4. **How to run it.** How to start the app or run the code, the login,
   and the data reviewers use. Seed data now if it's needed, and give
   each reviewer its own project or copy where the app allows.
5. **Out of bounds.** Behaviour, APIs, schemas or files that must not
   change.
6. **Reviewers.** How many (2 by default), and each one's model, effort
   and lens. A lens is 3–5 lines: who the reviewer is, what they need,
   what they notice first. Draft the lenses and get approval. With no
   lens, a reviewer judges as a neutral expert.
7. **Implementer.** Model and effort. Always exactly one.
8. **Stop time.** A date and time. Ask for the timezone if unclear.
9. **When usage runs out.** **Continue after reset** (default): wait out
   the 5-hour limit and carry on; a weekly limit ends the loop.
   **Stop**: any usage limit ends the loop.
10. **Start time.** Now (default), or a date and time before the stop.

## Check

- For **Continue after reset**, `~/.t3/userdata/settings.json` must
  contain `"autoResumeLimitedThreads": true`. If it doesn't, ask the user
  to turn on **Settings → Threads → Resume after usage limits**, and
  don't start until they have.
- Check this thread's runtime mode with `t3_thread_configure`. If it
  isn't full-access, tell the user an approval prompt would block the
  loop.
- If `.scratch` is not in `.git/info/exclude`, run `scratch-sync link` in
  the repo root.

## Write the run files

1. `context.md`: target and scope, hints, scores and their targets, how
   to run the app with data and login, what is out of bounds, the branch
   and repo path, and pointers to the repo's domain docs (`CONTEXT.md`,
   ADRs, style guides).
2. Copy this skill's `briefs/` into the run's `briefs/` with `cp`.
3. `state.json` with `status: setup`.

## Start

If `startAt` is null, go to [Map and go](#map-and-go). Otherwise:

1. Call `schedule_task` with `schedule: {type: "once", runAt: <startAt>}`,
   `bindToCurrentThread: true`, title `hill-climb <slug>`, and the
   prompt: "Use the hill-climb skill. Start the scheduled hill-climb in
   `.scratch/hill-climb-<slug>/`. Ask no questions."
2. Record `scheduledTaskId` and set `status: scheduled`.
3. Tell the user when the loop starts, and that if T3 is closed then it
   starts when T3 next opens. End the turn.

## Map and go

Also run by `loop.md` at a scheduled start.

1. Create `branch` from the current commit. Record `baseCommit` and
   `roundCommits["0"]`. Run every score at it and record
   `scoreHistory["0"]`.
2. Launch the map task with the implementer's model, `role: "review"`:
   the run directory's absolute path, then "Read `briefs/map.md` and
   follow it." Set `phase: mapping`.
3. When it returns, check `map.md` and `map-baseline.md` exist. Set
   `status: running`, `phase: implementing`, `round: 1`. Post a one-line
   summary of the settings and: "From here the loop runs on its own.
   Send a message to steer it, or say stop." Then read `loop.md` and
   launch the round 1 implementer.
