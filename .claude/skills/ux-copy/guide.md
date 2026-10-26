# UI copy guide

UI copy is the text a user reads while filling in a form, changing a setting or
recovering from an error. It is reference, not prose: the user scans it to
decide what to enter or click. Each string tells them what something is, what
it changes, or what to do next, in plain complete sentences.

A repo's own style guide (for example `docs/agents/ui-style.md`) wins over this
one where they differ.

## Every string

- Write complete sentences with a subject and a verb, ending in a full stop.
  Labels, buttons and headings are the exception: they are short phrases with
  no full stop.
- Use sentence case.
- Use the plain word a user of this app would use. Name a thing the same way
  everywhere it appears, matching the labels already on screen.
- Keep every piece of context the user needs to act: what the control is for,
  what changing it does, where to go next. Cut only what they cannot act on,
  such as how the code works internally.
- Phrase rules positively. "Files not in any list above are treated as
  source." beats "Files that match none of the lists count as source."
- Address the task, not the user. "Enter a label." rather than "You'll want to
  enter a label here."
- Check every claim against the code: thresholds, units, scope, which case it
  applies to. Wrong copy is worse than missing copy.

## By element

| Element | What it says | Example |
| --- | --- | --- |
| Label | The name of the value, as a noun phrase | Decimal places |
| Hint | The constraint or format needed for a valid value | A whole number from 0 to 10. |
| Placeholder | Empty, or a format sample only | #4a7c59 |
| Setting description | What changes when this setting changes | Hunks matching these rules are marked Scrutinise. |
| Page description | What the page controls, in one sentence | Rules that decide how Diffa marks each hunk. |
| Button | Verb plus object | Add framework |
| Confirmation | A question, then buttons that repeat the verb | Delete this framework? [Delete] [Cancel] |
| Error | What is wrong, then how to fix it | Minimum must be a number. |
| Empty state | What is missing, as a statement | This project has no frameworks. |
| Status | One or two words | In use |
| Tooltip | What the control does, as a sentence | Returns the square root of x. |

- An example belongs in the hint or description, never in the placeholder. A
  placeholder disappears as soon as the user types.
- A hint longer than one short sentence goes in a tooltip on an (i) icon beside
  the label, shown when the icon is hovered or focused.
- Mark required fields the way the app already does. Leave optional fields
  unmarked.
- A description that only repeats its label adds nothing. Leave it out.
- A number on a button or status names what it counts: "Summarise next 20
  files", not "Next 20".

## Before and after

These come from rewrites the user approved.

| Before | After |
| --- | --- |
| No project frameworks yet. | This project has no frameworks. |
| Locked (tooltip: A window has a result for it) | In use |
| A window has a result for this framework, so it can't be changed. Clear those results to edit it. | This framework is in use and cannot be edited. To edit it, clear it from all windows that use it. |
| Scores each window from its inputs, like RMR | Calculates a score from the inputs. |
| Add a number or dropdown input first | No number or dropdown inputs. Add one to use it in the formula. |
| {name}: min must not be more than max. | {name}: Minimum must be less than or equal to maximum. |
| Fill in the required inputs to see the Result | Fill in all required inputs to calculate the result. |
| Configurable location, geology forms and RMC framework results are cleared because they are project-specific. | Moving these captures clears their configurable location, geology forms and RMC framework results. These are specific to each project. |
| Diffa marks each hunk Skim, Read or Scrutinise so you can filter the summaries. These rules decide which. | Diffa marks each hunk with Skim, Read or Scrutinise to help filter summaries. Use the rules below to tweak the categorization. |
| 38 files and 9 trivial hunks. Summaries run in batches. | 38 files and 9 trivial hunks. Generate summaries in batches. |
| Without a risk flag, file role and changed lines decide between skim and read. The review reloads when you leave settings. | (deleted) |
