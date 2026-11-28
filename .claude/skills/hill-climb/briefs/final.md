# Final brief

This run is an experiment on its own branch, never pushed or merged, so
the run is the user's sign-off. This overrides any repo rule that asks
for sign-off before tests, removals or commits. Every other repo rule
holds: never push, open an MR, write to the tracker or touch production
data. Don't edit any file except the two below, and don't commit.

1. **Inventory.** Compare `map-baseline.md` with `map.md` and with the
   code at the last commit. List every baseline entry that is gone, and
   for each say whether a `rounds/*/implementer.md` removed it on
   purpose, with the round and reason. Write `rounds/final/inventory.md`.
   It is a record, not findings.
2. **Structure.** Review the diff from `baseCommit` in `state.json`:
   duplicated components or logic that should share one, components that
   should reuse something already in the repo, dead code the run left,
   and files that do several jobs. Write `rounds/final/structure.md`
   with findings in the format of `briefs/reviewer.md`.

Reply with both paths and the finding count.
