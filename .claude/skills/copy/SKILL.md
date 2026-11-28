---
name: copy
description: Write, rewrite or review text people read to get something
  done. Use for UI strings (labels, hints, buttons, errors, empty states,
  confirmations, notifications, tooltips, settings), READMEs, docs,
  instructions, form text, taglines and abstracts. Also use when asked to
  fix, tighten or review copy.
---

# Copy

Models know the rules of good copy and still write bad copy. The text comes
out in the same templates every time, the sentences are either crammed or
clipped, and "it" points at three different things. This skill works in
three ways:

- Each kind of text has a pattern, in [patterns.md](patterns.md).
- Every draft imitates real text that people wrote before LLMs, in
  `examples/`.
- Every draft gets a second, separate read that looks for the problems the
  writer can't see while writing, using [review.md](review.md).

## Scope

Fix all the copy in the area you were asked to work on, including text
that was already there. Existing text isn't correct just because it exists,
and it was often written by a model too. Don't touch text outside that area.

## Steps

1. **Say what each piece of text is:** a button, an error, a
   README intro, a tagline, a setting description. Then say who reads it
   and what they're doing at that moment. Someone fixing a failed payment
   reads differently from someone browsing a feature list.
2. **Get the facts.** Read the code or the subject: what the thing does,
   its limits and units, what happens next, and the words the rest of the
   product already uses for the same things. If you can't check a claim,
   leave it out. Wrong copy is worse than missing copy.
3. **Read real examples.** Before drafting each kind of text, read 5 to 10
   examples of it:
   - `grep -i '<word>' examples/<element>.tsv | head -20`, with a word
     from the meaning, such as `delete`, `date` or `connect`. The files are
     `error`, `hint`, `button`, `label`, `heading`, `description`, `empty`,
     `confirmation`, `tooltip` and `body`.
   - The matching section of `examples/do-dont.md`
     (`grep -n '^## <component>' examples/do-dont.md`).
   - The matching guide in `examples/guides/`, such as
     `govuk-error-message.md` or `govuk-confirmation-pages.md`.
   - For a README or docs, the opening and headings of three files in
     `examples/docs/`.

   The TSV rows mix GOV.UK and Firefox. Firefox uses Title Case and some
   of its marketing strings are cute ("Oops!", "Poof"). Where the two
   disagree, follow GOV.UK.
4. **Draft.** Use the pattern for that kind of text from
   [patterns.md](patterns.md), and match the examples' length and plain
   words. Say each thing once, fully, in the order the reader needs it.
5. **Review.** Do the separate read in [review.md](review.md). If you can
   start a subagent, give it only the draft and `review.md`, not the code
   or your notes. A reader who doesn't know what you meant is the one who
   finds the unclear "it". Otherwise, do the review yourself as a separate
   pass, one sentence at a time.
6. **Check against [tells.md](tells.md)** and rewrite each match.

## Output

For UI strings, show a table of each string with its current and proposed
text, then apply what the user approves. For a README or docs, write the
file and list what you cut and why in a sentence each.
