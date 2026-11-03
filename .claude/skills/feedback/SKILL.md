---
name: feedback
description: Apply one round of UI and iteration feedback to already-implemented work, inline on Sonnet.
argument-hint: "[the whole feedback message]"
disable-model-invocation: true
model: sonnet
effort: high
---

Apply the feedback below to the work already in this conversation. A round is a set of concrete asks
(reuse a component, match the site's styling, fix a bug), so work inline from the context and files already loaded.

<feedback>
$ARGUMENTS
</feedback>

If the feedback block is empty, ask for the feedback and stop.

## 1. List the items

Split the feedback into a numbered list of discrete items, one per ask.
The round is complete when every item has a final status: done, check visually, escalated, or blocked.

## 2. Triage

Mark an item **escalated** when it changes an agreed decision (data model, module boundaries,
a public interface, a ticket's chosen approach) or its intent is still ambiguous after reading the relevant code.
Leave escalated items untouched: they go back to the parent model. Every other item is in scope.

## 3. Apply

Work the in-scope items in order.

- Scope each change to its item. Note any refactor or cleanup you spot as a suggestion in the report.
- Work from files already read in this conversation; read a file again only when it may have changed or is required to complete the task.
- For a bug whose cause is unclear after reading the code, mark it **escalated**.
- When an item cannot be completed (missing asset, failing dependency, contradicts another item), mark it **blocked** and move on.

## 4. Verify

Run typechecking, lint, and format files covering the changed code. The step is done when typechecking and lint passes.
Mark an item **check visually** when its result is visual and you cannot observe it.

## 5. Commit

Commit the round to the current branch as one commit.

## 6. Report

One line per item: number, status, and a one-line reason for any escalated or blocked item. Add suggestions from step 3 as a short list after the items, if any.
