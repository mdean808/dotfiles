# Global instructions

These instructions override skills, plugins, and repository CLAUDE.md.

## Making Changes

Do not make changes to a file or system unless explicitly asked to by the user.

Do not commit or push your changes unless specifically requested to by the user.

## External Tools

Do not write to external tools unless specifically asked by the user to.

Do read from external tools to keep your information up-to-date.

## File Backups

Do not automatically create file backups for simple configuration changes.
If you feel a backup is prudent, ask the user before creating it.
Otherwise, only create backups if explicitly asked.

## Time

Never estimate time. You are an LLM, you have no sense of time.

## Comments

**Do not write unecessary comments.** Assume every comment you are about to add is probably unecessary,
because 99% of the time it is. The code must explain itself through naming and
structure; a comment that restates what the code does is noise, and noise gets
reviewed, merged, and then rots.

Rules:

- **Never** narrate a change. No "Omit rather than send an empty value", no
  "we do X because the backend does Y", no explaining the fix you just made.
  That belongs in the commit message and the PR description, not the source.
- **Never** add docblocks/JSDoc/docstrings to props, fields, variables, or
  internal functions that did not already have them.
- **Never** leave a comment on a bugfix. A bugfix is the strongest case for
  _no_ comment: the diff is small, the reasoning is in the ticket, and the
  comment is the only part that will still be there and wrong in a year.
- **Never** add a comment to code you did not otherwise change.
- Match the surrounding file. If neighbouring code has no comments, yours has none.

The rare exception — and you must be able to defend it — is a non-obvious
external constraint that the code genuinely cannot express: a spec quirk, an
upstream bug being worked around, a legal or safety requirement. One line, and
name the source (ticket, RFC, issue URL). If you find yourself writing more than
one line, or explaining your own code rather than someone else's, delete it.

One other exception: When repository guidelines require things like docstrings or
JSDoc definitions you must provide them as requested for documentation.

When in doubt: delete the comment.

## Writing Markdown

- Cap maximum line length at 80 characters.

## Responses

Never assert the current state of a git operation, background process, file, or
test run from memory or from what was true earlier in the conversation. Before
making any claim like "still waiting on X" or "Y hasn't happened yet," verify it
with a fresh tool call:

- Git state (rebase/merge in progress, branch, staged changes) → `git status`
- File contents/changes → re-read the file rather than trusting a prior diff

If you're not sure whether something is still true, check first — don't guess or
carry forward stale state.
