# Reviewer brief

This run is an experiment on its own branch, never pushed or merged, so
the run is the user's sign-off. This overrides any repo rule that asks
for sign-off before tests, removals or commits. Every other repo rule
holds: never push, open an MR, write to the tracker or touch production
data. Don't edit any file except your result file, and don't commit.
Don't save to shared data unless a check needs it, and undo what you can.

Your job is to find what's still wrong, and you find it by going deep, not
wide. Anyone can screenshot a page and spot a misaligned button. You're
here for what only shows when you push on the thing: wrong results, lost
data, states nobody handled, behaviour that breaks on the second try.

## Start

Read `context.md` and `map.md`. Run `git diff <previous> <commit> --stat`
to see what this round touched.

1. **Previous findings.** For each one in your previous file, rerun the
   original steps, then vary them: other inputs, other entry points, the
   same action twice. A fix that only passes the exact steps is still
   open.
2. **Pick where to dig.** Choose 2–3 areas: what this round's diff
   touched, the hints in `context.md`, and areas `log.md` shows nobody
   has dug into yet. Don't spread thin over the whole map.

## Depth

For each area you picked:

1. **Read the code first.** Its handlers, conditions, error paths, state,
   and what it reads and writes. Each branch and each unhandled case is
   something to try.
2. **Use it for real**, end to end, with realistic data, and check the
   outcome where it lands, not where the UI says it did: the API
   response, the stored row, the file, the reloaded page.
3. **Push on it.** Empty, huge, invalid and boundary input. Do it twice,
   undo and redo, cancel halfway, reload mid-action, go back, switch
   tools mid-task, act while it's still loading, use the keyboard only.
   Combine features the map lists separately.
4. **Follow each problem to its cause.** Find the line responsible, then
   search for the same pattern elsewhere and check those too.
5. Only when an area holds up after all that, move to the next one.

Don't pad. A short list of real findings beats a long list of nits. If an
area holds up, say what you tried.

## What the preview tools can't drive

- **Drag and resize**: dispatch pointer events with `preview_evaluate`
  and compare `getBoundingClientRect()` before and after.
- **Layout shift**: record element rects before and after opening a
  panel, showing an error or loading data, or read `layout-shift`
  entries. Find the cause in the code.
- **Animation**: list `document.getAnimations()` and read the CSS
  transitions. Don't judge motion from screenshots.
- **Hover and focus**: read the `:hover` and `:focus-visible` styles.
- A map entry missing from the app, or something in the app missing from
  the map, is a finding.

Close any preview tab you opened.

## Output

Write your result file in this format, then reply with its path and the
counts.

    ---
    reviewer: <id>
    round: <n>
    commit: <sha>
    blocker: 0
    major: 0
    minor: 0
    ---

    ## Dug into

    - <area>: what you read, what you tried, what held up

    ## Previous findings

    - <id> fixed | open | regressed: one line, and the variations you tried

    ## Findings

    ### <n>-<id>-<k> [blocker|major|minor] [seen|simulated|code]

    Where: screen and state, and `file:line` of the cause.
    Steps: the exact input and actions.
    What happens, and what should happen.
    Same pattern elsewhere: paths, or none found.

- **blocker**: wrong result, data loss, a crash, or a map feature gone. A
  regression is a blocker; mark it `regressed` and name the round that
  broke it.
- **major**: confusing, slow or needs a workaround; a visible layout
  shift; inconsistent behaviour across tools.
- **minor**: copy, spacing, styling.
- The tag says how you checked: seen in the app, simulated with events,
  or read from the code.
