# Patterns

Each kind of text has a job, a shape and a length. The examples are real
strings from `examples/`. When a pattern here and the examples disagree,
the examples win.

## Interface text

### Heading or page title

- Job: tells the reader where they are or what they're about to do.
- Shape: a noun phrase or a task, in sentence case. "Account settings",
  "Change your address".
- Length: 2 to 6 words.

### Button or link

- Job: says what happens when it's pressed.
- Shape: a verb, plus an object when the verb alone is unclear. "Save and
  continue", "Delete", "Export logins". Link text says where the link
  goes: "Read the privacy policy", not "Click here".
- Length: 1 to 4 words.
- The verb matches the action. If the button deletes for good, it says
  "Delete", not "Remove".

### Label

- Job: says what value the reader enters or sees.
- Shape: a noun phrase. "Date of birth", "Email address".
- Length: 1 to 4 words.

### Hint

- Job: the one fact needed to answer, such as the format or where to find
  the answer. "For example, 31 3 1980". "It's on your National Insurance
  card, benefit letter, payslip or P60."
- Leave out the hint if it would only repeat the label.
- Length: one short sentence or phrase.

### Inline error

- Job: says what's wrong with this field and how to fix it, using the
  field's own words.
- Shape: "Enter [thing]" when it's missing, and "[Thing] must be [rule]"
  when it breaks a rule. "Enter a real postcode". "Job description must be
  350 characters or less".
- Length: under 12 words. No "please", "invalid" or "error".

### System error

- Job: says what failed, and what the reader can do now.
- Shape: "[What failed]. [What to do]." Add the cause only when it changes
  what the reader does. "Video can't be played because the file is
  corrupt." Use the real cause from the code. Don't guess "check your
  connection" when the failure isn't a network one.
- Length: 1 or 2 sentences.
- Don't add "Try again later" to every error. Use it only when retrying
  will help.

### Empty state

- Job: says what's missing, as a fact, and the action that fills the space
  if there is one.
- Shape: "No [things]" or "You don't have any [things]". "No logins
  found". "You don't have any add-ons of this type installed".
- Length: one line, plus a button if there's an action.
- No "yet", no "You're all caught up", no cheerleading.

### Success message

- Job: confirms what happened.
- Shape: past tense with the object. "Changes saved", "Address updated",
  "New code sent".
- Length: 2 to 5 words. No exclamation mark.

### Confirmation dialog

- Job: makes the reader stop before something they can't undo.
- Shape: the question says the action and the object. The body says what
  will be lost. The button repeats the verb. "Delete this playlist?"
  "The songs stay in your library." Buttons: "Delete playlist", "Cancel".
- Use a dialog only when the action can't be undone.

### Notification or banner

- Job: tells the reader something changed that they didn't do themselves,
  or something they need to act on.
- Shape: what happened, then the action. "An update to Firefox started in
  the background. You'll need to restart to finish the update."
- Length: 1 or 2 sentences.

### Tooltip

- Job: says what an icon does, or adds one fact that doesn't fit on screen.
- Shape: like a button for icons ("Copy link"), or like a hint for facts.
- Length: under 10 words.

### Setting description

- Job: says what changes when the setting is on.
- Shape: one sentence, in the present tense. "Send me an email when an
  order ships." Don't explain how it works unless that changes the choice.

## Longer text

### Tagline or one-line description

- Job: says what the thing is, for anyone who reads it.
- Shape: "[Name] is a [kind of thing] that [does what]", or two short
  sentences. It describes the product, so it doesn't talk to one person
  with "you" or "your". "jq is a lightweight and flexible command-line JSON
  processor." "fd is a program to find entries in your filesystem."
- Length: 1 or 2 sentences. The tagline is a pitch, so leave out how it
  works and any caveats. The body covers those.

### README

- The opening is the one-line description above.
- Next comes what it does differently from the obvious alternative, in a
  short paragraph. Then come install and usage, with commands the reader
  can copy.
- Headings are plain nouns or tasks: "Install", "Usage", "Configuration".
- Each section holds only what someone doing that task needs. Install says
  how to install and update. It doesn't reassure the reader about edge
  cases they haven't hit.

### Instructions

- One action per step, starting with the verb. Say what the reader will
  see when the step worked, if that isn't obvious.
- Put conditions before the action: "If the build fails, run X", not "Run
  X if the build fails".

### Abstract

- Problem, method, result, in that order. Give the result's number.

## Tone

Tone follows the stakes, not a brand voice.

- Routine actions get the fewest words: "Saved".
- Errors are calm and specific. Don't apologise and don't joke.
- Actions that can't be undone are plain and serious, and say what will be
  lost.
- Success gets no more celebration than the task deserves. Most tasks
  deserve none.

## Accessibility

- Every icon-only button has a label that works out of context: "Delete
  invoice", not "Delete" when there are ten on the page.
- An error mentions its field, so a screen reader that reads the error alone
  still makes sense.
- Don't rely on colour or position ("the red button", "below") to carry
  meaning.
- Use the same word for the same thing everywhere. If the product says
  "project", don't write "workspace" in one place.
