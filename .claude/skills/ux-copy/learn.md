# /ux-copy --learn

Turn the user's changes in `feedback.md` into edits to `guide.md`. The guide
stays a list of one-line rules and before/after examples. Feedback rows are
evidence for an edit, never text to paste into the guide.

## Rules

- Change only `guide.md`, `feedback.md` and `feedback-archive.md`.
- Every guide change is one of the operations below, approved by the user
  one at a time. Never rewrite a section, add a section, or add prose.
- Do not touch rules or examples that no feedback row bears on.

## Operations

| Operation | Evidence needed | Change |
| --- | --- | --- |
| `add-rule <section>` | 2 or more rows | One imperative line under an existing section |
| `edit-rule` | Rows the current wording got wrong | Rewords one existing line |
| `remove-rule` | Rows where the user undid what the rule asked for | Deletes one line |
| `add-example` | 1 row | One row in the before/after table, Before = current, After = final |
| `retire-example` | A rule that now covers it | Deletes one before/after row |

A pattern seen once becomes an example, not a rule.

## Steps

1. **Read.** Read `guide.md` and `feedback.md`. Number the feedback rows F1,
   F2 and so on in file order. Stop if there are none.
2. **Sort.** For each row, compare proposed and final and name the
   difference in a few words. Group rows by difference. Each row is one of:
   - evidence for an operation,
   - already covered by a guide rule the proposal broke (a drafting miss,
     not a guide gap),
   - not enough on its own yet (a single row whose pattern you expect to
     recur but which is too specific for an example).
3. **Propose.** Write the operations:

   ```
   1. add-rule · Every string
      + Write "cannot", not "can't".
      Evidence: F3 (diffa), F7 (lithos)
   ```

   When all evidence for a rule comes from one repo, say so. The rule may
   belong in that repo's style guide instead.
4. **Budget.** The guide stays under 120 lines and 20 before/after rows. If
   the operations would exceed either, add `retire-example` or merge rules
   until they fit.
5. **Lint.** Check the guide as it would be after every operation:
   - each rule is one line,
   - no rule repeats or contradicts another,
   - every After in the before/after table obeys every rule,
   - no hedging ("consider", "try to", "where possible", "ideally").

   Fix the operations, or list the violation beside the operation if it was
   already in the guide.
6. **Approve.** Show the operations as a numbered list and ask which to
   apply. Apply only those.
7. **Archive.** Move each row that an operation cited, approved or not, and
   each drafting-miss row from `feedback.md` to `feedback-archive.md`, adding
   the outcome column: the operation number and `applied` or `rejected`, or
   `drafting miss`. Rows that are not enough on their own stay in
   `feedback.md`. Done when every F-number is either archived or still in
   `feedback.md`, and none is in both.

## Report

- The operations applied and rejected.
- Drafting misses, grouped by the rule that was broken. A rule missed often
  may need moving higher in the guide or rewording.
- How many rows stay in `feedback.md`.
- Guide line count and before/after row count against the budget.
