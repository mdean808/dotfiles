---
name: ux-copy
description: Write or rewrite UI copy (form labels, hints, placeholders,
  errors, tooltips, empty states, settings descriptions, button text). Use
  when adding or changing user-facing strings in an app, or when the user
  asks to fix copy, wording or labels.
---

# /ux-copy

Arguments: `$ARGUMENTS`

Read [guide.md](guide.md) before drafting. It, plus any style guide the repo's
CLAUDE.md points to, is the standard every string is checked against. The
unslop rules do not apply to UI strings.

## Steps

1. **Collect.** List every string in scope: the strings the user named, or
   every user-facing string in the files or feature they named. For each one,
   record the element type, the file and line, and what it does, read from the
   code (limits, units, which cases it covers). Done when every string in
   scope has a verified behaviour.
2. **Draft.** Write a proposal for each string that breaks the guide, using the
   verified behaviour. Wording the user supplied is used as given, after an
   accuracy check.

   With `--agent` in the arguments, hand the draft to the `ux-copy-writer`
   agent instead. Send it the path to `guide.md`, the repo style guide path if
   there is one, and the collected list. It has no code access, so the list
   carries everything it needs.
3. **Check.** Hold each proposal against the code and the guide. A claim that
   does not match the code is rewritten before the user sees it.
4. **Propose.** For more than a handful of strings, go one section (one
   component or screen) at a time. Show a table of Element, Current and
   Proposed, list the strings that stay unchanged in one line, and ask which
   rows to apply. A few strings with an unambiguous fix are applied directly.
5. **Apply.** Change only the approved rows, update tests that assert on the
   old text, and run them. Report what changed and any choice the user did not
   approve explicitly.
