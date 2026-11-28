---
name: copy
description: Write, rewrite or review text people read to get something
  done. Use for UI strings (labels, hints, buttons, errors, empty states,
  confirmations, notifications, tooltips, settings), READMEs, docs,
  instructions, form text, taglines and abstracts. Also use when asked to
  fix, tighten or review copy.
---

# Copy

Models know the rules of good copy and still write bad copy. They reuse
the same templates, cram or clip their sentences, and use one "it" for
three different things. This skill counters those habits in three ways:

- [patterns.md](patterns.md) gives the pattern for each kind of text.
- Every draft is modelled on real text in `examples/`, which people wrote
  before LLMs.
- Every draft gets a second, separate read against
  [review.md](review.md). That read finds the problems a writer can't see
  while writing.

## Scope

Fix all the copy in the area you were asked to work on, including text
that was already there. Shipped text can still be wrong, and a model often
wrote it. Leave text outside that area alone.

## Steps

1. Say what each piece of text is, such as a button, an error, a README
   intro, a tagline or a setting description. Then say who reads it and
   what they're doing at that moment. Someone fixing a failed payment
   reads differently from someone browsing a feature list.
2. Get the facts. Read the code or the subject to learn what the thing
   does, its limits and units, and what happens next. Note the words the
   product already uses for each thing the text mentions. If you can't
   check a claim, leave it out.
3. Cut weak lines from the existing text. Before you rewrite it, read
   each line against checks 3 and 4 in [review.md](review.md). Delete
   every line that fails, then rewrite the lines that are left.
4. Read real examples of each kind of text before you draft it. Read 5 to
   10 strings, or 3 files for a README or docs:
   - Search the strings with
     `grep -i '<word>' examples/<element>.tsv | head -20`. Use a word from
     what the string means, such as `delete`, `date` or `connect`. The
     files are `error`, `hint`, `button`, `label`, `heading`,
     `description`, `empty`, `confirmation`, `tooltip` and `body`.
   - Read the matching section of `examples/do-dont.md`, which holds
     Shopify Polaris's do and don't pairs
     (`grep -n '^## <component>' examples/do-dont.md`).
   - Read the matching guide in `examples/guides/`, such as
     `govuk-error-message.md` or `govuk-confirmation-pages.md`.
   - For a README or docs, read the opening and headings of three files
     in `examples/docs/`.

   The TSV rows come from GOV.UK and Firefox. Firefox uses Title Case,
   and some of its marketing strings are cute ("Oops!", "Poof"). Where
   the two disagree, follow GOV.UK.
5. Draft the text with its pattern from [patterns.md](patterns.md), and
   match the length and plain words of the examples. Say each thing once
   and in full, in the order the reader needs it.
6. Review the draft with the separate read in [review.md](review.md),
   then check it against [tells.md](tells.md). If you can start a
   subagent, give it the draft, who reads it, `review.md` and `tells.md`.
   Don't give it the code or your notes. A reader who doesn't know what
   you meant is the one who finds the unclear "it". If you can't start
   one, do both checks yourself as a separate pass, as `review.md`
   describes.

## Output

For UI strings, show a table with the current and proposed text of each
string. Write "Delete" as the proposed text for each line you cut. Then
apply the changes the user approves. For a README or docs, write the
file, then list what you cut and why, in one sentence for each cut.
