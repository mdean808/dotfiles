# Global instructions

These instructions override skills, plugins, and repository CLAUDE.md.

## Making Changes

Do not make changes to a file or system unless explicitly asked to by the user.

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

**Do not write unnecessary comments.** Assume every comment you are about
to add is probably unnecessary, because 99% of the time it is.
The code must explain itself through naming and structure;
a comment that restates what the code does is unnacceptable.

Rules:

- **Never** narrate a change. For example, avoid comments like this:
  - "Omit rather than send an empty value"
  - "we do X because the backend does Y"
- **Never** leave a comment on a bugfix. A bugfix is the strongest case for _no_ comment.
- **Never** add a comment to code you did not otherwise change.

The rare exception — and you must be able to defend it — is a non-obvious
external constraint that the code genuinely cannot express: a spec quirk, an
upstream bug being worked around, a legal or safety requirement. One line, and
name the source (ticket, RFC, issue URL). If you find yourself writing more than
one line, or explaining your own code rather than someone else's, delete it.

One other exception: When repository guidelines require things like docstrings or
JSDoc definitions you must provide them as requested for documentation.

When in doubt: delete the comment.

## Subagents

- Spawn a subagent only when a search would pull many files into context
  and only the conclusion matters.
- Implement in the main session, unless the plan has 3 or more slices. Then
  implement each slice in its own Sonnet subagent with a tight brief: the
  files, the acceptance criteria, the decisions, and no re-exploring. Keep the
  main session for my feedback and the adjustments I ask for.
- Run chores on Sonnet: commits, rebases, conflict cleanup, flag toggles,
  seeding dev data, dotfiles. Use `/ship` for commits.
- Do not review changes unless the user asks for a review or a skill calls
  for one. Exception: skills a subagent wrote or changed get one fresh `opus`
  review against `create-skill` before you report them done. One reviewer
  covers every skill from that piece of work.
- When a review happens, run it in one fresh subagent, never in the session
  that wrote the code. One reviewer covers spec, standards and bugs. Add a
  separate security reviewer only when the change touches auth, payments,
  user data or permissions.
- Pick the subagent model by task:
  - `haiku` for narrow lookups: where something is defined, which files
    use it, what a config value is. Use Explore on `haiku` to map unfamiliar
    code.
  - `sonnet` for research that traces behaviour across
    files, and for running commands.
  - `opus` for review and diagnosis.
- Give a subagent the paths and findings you already have, so it does not
  rediscover them.
- Ask subagents to report conclusions with file paths and line numbers, not
  file contents.
- Do not ask Explore for a "very thorough" search unless the question spans
  the whole repo.

## Grilling

- Don't ask what the feature can't exist without, or what the user already
  stated.
- Ask only what changes the work. Assume the rest and list the assumptions.

## Scope

Do what I asked and nothing more. If a bigger change looks better, say so and
wait. Don't change copy, colors or layout I didn't mention. When I say I'll
hand work to another agent, write the handoff and stop.

## Writing

Before writing anything that isn't a chat reply, name what it is: UI string,
settings text, report, MR description, QA steps, ticket, status update. Write
that thing, not a message to me. Keep it simple, no word salad. Reports answer
the question first, then show evidence.

## Files

Read a file with Read before you edit it, and read only the range you'll
edit. Use Bash only to search, or to read files you won't edit. This overrides
the bypass-mode guidance to read and edit files through Bash.

## Tests

Don't run tests mid-change unless I ask. When tests run, use the repo's test
skill if it has one, and run suites in parallel and in the background.

## Skills

When `/implement` says to call `tdd`, skip it unless I ask for TDD.

## UI

- Avoid creating layout shifts when adding new features.

## Writing Markdown

- Cap maximum line length at 80 characters.
