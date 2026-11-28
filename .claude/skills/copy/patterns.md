# Patterns

Each pattern gives a kind of text its job, and most give a shape and a
length. The example strings in the interface text and tagline patterns
all come from `examples/`. When a pattern here and the GOV.UK examples
disagree, follow the examples.

## Interface text

### Heading or page title

- Job: tells the reader where they are or what they're about to do.
- Shape: a noun phrase or a task, in sentence case. "Your details",
  "Change your cookie settings".
- Length: 2 to 6 words.

### Button or link

- Job: says what happens when the reader presses the button or follows
  the link.
- Shape: a verb, plus an object when the verb alone is unclear. "Save and
  continue", "Delete account", "Export". Link text says where the link
  goes. Don't write "Click here".
- Length: 1 to 4 words.
- The verb matches the action. A button that deletes something for good
  says "Delete", because "Remove" suggests it can come back.

### Label

- Job: says what value the reader enters or sees.
- Shape: a noun phrase. "Email address", "Passport number".
- Length: 1 to 4 words.

### Hint

- Job: gives the one fact the reader needs to fill in the field, such as
  the format or where to find the information. "For example, 31 3 1980".
  "It's on your National Insurance card, benefit letter, payslip or P60."
- Leave out a hint that would repeat the label.
- Length: one short sentence or phrase.

### Inline error

- Job: says what's wrong with this field and how to fix it, using the
  words in the field's label.
- Shape: "Enter [thing]" when the value is missing, and "[Thing] must be
  [rule]" when it breaks a rule. "Enter a real postcode". "Job
  description must be 350 characters or less".
- Length: under 12 words. No "please", "invalid" or "error".

### System error

- Job: says what failed, and what the reader can do now.
- Shape: "[What failed]. [What to do]." "Firefox does not have permission
  to read the file. Try changing the file permissions." When the cause
  changes what the reader does, add it. Use the real cause from the code.
  Don't guess "check your connection" when the failure isn't a network
  one.
- Length: 1 or 2 sentences.
- When retrying will help, add "Try again later". Otherwise leave it out.

### Empty state

- Job: says what's missing, as a fact, and gives the action that fills
  the space if there is one.
- Shape: "No [things]" or "You don't have any [things]". "No logins
  found". "You don't have any add-ons of this type installed".
- Length: one line, plus a button if there's an action.
- No "yet", no "You're all caught up", no cheerleading.

### Success message

- Job: confirms what happened.
- Shape: past tense with the object. "New code sent".
- Length: 2 to 5 words. No exclamation mark.

### Confirmation dialog

- Job: makes the reader stop before something they can't undo.
- Shape: the question says the action and the object. The body says what
  the reader will lose. The button repeats the verb. "Discard unsaved
  changes?" "All unsaved changes will be lost." Buttons: "Discard",
  "Cancel".
- Use a dialog only for an action that can't be undone.

### Notification or banner

- Job: tells the reader about a change they didn't make themselves, or
  something they need to act on.
- Shape: what happened, then the action. "An update to Firefox started
  in the background. You'll need to restart to finish the update."
- Length: 1 or 2 sentences.

### Tooltip

- Job: says what an icon does, or adds one fact that doesn't fit on the
  screen.
- Shape: like a button for icons ("Translate this page"), or like a hint
  for facts.
- Length: under 10 words.

### Setting

- Job: says what happens when the setting is on.
- Shape: a verb phrase in the present tense. "Warn you when websites try
  to install add-ons". "Confirm before closing multiple tabs". When
  knowing how the setting works changes the reader's choice, explain it.

## Longer text

### Tagline or one-line description

- Job: says what the thing is, for anyone who reads it.
- Shape: "[Name] is a [kind of thing] that [does what]", or two short
  sentences. A tagline describes the product, so it doesn't address one
  person as "you". "ripgrep is a line-oriented search tool that
  recursively searches the current directory for a regex pattern."
  Leave out how the thing works and any caveats, because the body covers
  those.
- Length: 1 or 2 sentences.

### README

- The opening is the one-line description above.
- Next comes a short paragraph on what the tool does differently from
  the obvious alternative. Then come install and usage, with commands the
  reader can copy.
- Headings are plain nouns or tasks: "Install", "Usage",
  "Configuration".
- Each section holds what someone doing that task needs and nothing else.
  Install says how to install and update. It doesn't reassure the reader
  about edge cases they haven't hit.

### Instructions

- Give one action per step, starting with the verb. Say what the reader
  will see when the step worked, if that isn't obvious.
- Put conditions before the action: "If the build fails, run X", not
  "Run X if the build fails".

### Abstract

- Give the problem, the method and the result, in that order. Give the
  main result as a number.

## Tone

Match the tone to the stakes, whatever the brand voice.

- Routine actions get the fewest words.
- Errors are calm and specific. Don't apologise and don't joke.
- Text before an action that can't be undone is plain and serious, and
  says what the reader will lose.
- Success gets no more celebration than the task deserves, which for
  most tasks is none.

## Accessibility

- Give every icon-only button a label that works out of context:
  "Delete invoice", not "Delete" when ten invoices are on the page.
- Put the field's name in its error, so the error makes sense when a
  screen reader reads it alone.
- Don't rely on colour or position, such as "the red button" or "below",
  to carry meaning.
- Use the same word for the same thing everywhere. If the product says
  "project", don't call it "workspace" anywhere.
