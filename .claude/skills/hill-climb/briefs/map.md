# Map brief

This run is an experiment on its own branch, never pushed or merged, so
the run is the user's sign-off. This overrides any repo rule that asks
for sign-off before tests, removals or commits. Every other repo rule
holds: never push, open an MR, write to the tracker or touch production
data. Don't edit any file except `map.md` and `map-baseline.md`.

Read `context.md`, then the code in scope. Write `map.md`: every route,
panel, dialog, tool and interaction in scope, including buttons, drag and
resize handles, keyboard shortcuts, context menus, hover and focus states,
transitions and animations, autosave and other side effects.

For each entry:

- what it does, and the file and component behind it;
- its states and branches: loading, empty, error, disabled, partial,
  permission-denied, and the conditions in its handlers;
- what it reads and writes: API calls, stores, storage, the database;
- how a reviewer checks it: **drive** (the preview tools can do it),
  **simulate** (dispatch events with `preview_evaluate`) or **read**
  (only the code shows it).

Find entries from the code, not only from what the screen shows: walk
the router, the component tree, event handlers and keybindings. Copy the
result to `map-baseline.md`. Reply with the entry count.
