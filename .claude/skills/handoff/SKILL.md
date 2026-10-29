---
name: handoff
description: Write context and instructions for another agent, then stop. Use when the user asks for context or instructions to hand to an agent.
allowed-tools:
  - Read
  - Write
  - Bash(ls *)
  - Bash(git status *)
  - Bash(git branch *)
---

# /handoff

Write a brief another agent can start from cold, then stop. The user hands it
over.

## Rules

- Write only the handoff file. No code, spec, plan, subagent or tracker
  write.
- Stop after writing. Don't start the deliverable, not even its first step.
- Record only decisions the user made. An open question goes under "Open".
- The reader can't see this conversation. Never write "as discussed".

## Steps

1. Use the `.scratch/` directory for the current ticket or feature, found as
   `~/.claude/rules/scratch-workflow.md` says. If there is none, make
   `.scratch/<feature-slug>/`.
2. Write the template to `handoff.md`, or to
   `handoffs/<KEY>-<n>-<slug>.md` in an epic directory. If the file exists,
   add `-v2`, `-v3` and so on, and leave the old one. Link files by path,
   never paste their contents.
3. Reply with the path and one line naming what the agent will produce.
   Done when nothing but that reply follows the file.

## Template

```markdown
---
issue: <KEY>-<n>
status: ready-for-agent
---

# Handoff: <deliverable in a few words>

## Read first
- `<path>`: <why it matters>

## Decisions
- <decision>. Why: <reason>

## Constraints
- <what must hold: scope, branch, security>

## Deliverable
<What to produce, where to write it, and what done looks like.>

## Open
- <unsettled question the agent may not decide>
```

Drop `issue:` when there is no ticket, and any heading with nothing under it.

## Gotchas

- "Hand off the spec" means the agent writes the spec. The deliverable is
  "write the spec", and you don't write it.
- The agent won't see the user's standing rules unless the constraints list
  them. Copy the ones that bear on the work from `~/.claude/CLAUDE.md` and
  `~/.claude/rules/`, such as the read-only tracker.
