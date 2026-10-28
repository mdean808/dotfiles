---
name: create-skill
description: Write or revise an agent skill. Use when the user asks to create a skill or change an existing one.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(ls *)
  - Bash(find *)
  - Bash(grep *)
  - Bash(git log *)
  - Bash(yadm status *)
  - Bash(yadm log *)
  - AskUserQuestion
---

# /create-skill

Arguments: `$ARGUMENTS` (what the skill should do, or the skill to revise)

A skill is worth writing only for what the agent would get wrong without
it. Every line costs context on every run, so each one has to name a
convention, a command, an edge case or a mistake the agent would make.

## Rules

- Write only the skill's own files.
- Personal skills go in `~/.claude/skills/<name>/`. A repo skill in
  `.claude/skills/` ships to the remote, so ask before writing one there.
- Revising a skill: read it and every file it points at fresh first, and
  keep its existing decisions unless the user asks to change them.

## 1. Gather real material

Build the skill from what is specific to this user and machine, not from
general knowledge. In order:

- If the user just did a task in this conversation: Use the steps that worked,
  their corrections, and the input and output formats.
- The files, commands, scripts and APIs the skill will touch. Read them.
- The rules it must keep: `~/.claude/CLAUDE.md`, `~/.claude/rules/`, and
  the repo's `CLAUDE.md` and `CLAUDE.local.md`.
- Existing skills: `ls ~/.claude/skills .claude/skills`. A skill that
  already covers the job gets extended instead.

If the material does not say what the skill should do in a case that
changes the result, ask. Done when you can state, for each step, what the
agent would do wrong without it.

## 2. Write the frontmatter

```yaml
---
name: <kebab-case, same as the directory>
description: <What it does, in a few words>. Use when the user asks to <x>, <y> or <z>.
allowed-tools:
  - <each tool and Bash(<command> *) the skill runs>
---
```

The description is one line: what it does, then when to use it, phrased as
the user's intent. Give one trigger per distinct case; synonyms for one case
count as one. Leave out how it works inside. The body says that.

```yaml
Bad:  description: Write a GitLab merge request description for the current
        branch's ticket into .scratch/<ticket>/ (mr.md, or mrs/ when it
        exists), built from the branch diff, commits and scratch notes.
Good: description: Write an MR description. Use when the user asks for an
        MR, merge request or PR description.
```

A skill the user only ever calls by name gets
`disable-model-invocation: true` and a one-line summary with no triggers.
It then costs no context and never fires on its own.

## 3. Write the body

Open with `# /<name>`, an `Arguments:` line in the form mr-desc uses when
the skill takes any, and one or two sentences that state the main idea.
Claude Code substitutes the arguments variable everywhere in the body, so
write it on that line only. Then add the
sections the skill needs, in this order:

- **Rules**: what the skill may write or change, what it leaves to the
  user (commits, pushes, tracker and GitLab writes), and when to stop and
  ask.
- **Steps**: numbered. Be strict where a step is fragile (an exact command,
  a set order) and loose where several approaches work. Give one default
  per choice, not a menu. End a step whose finish is unclear with a
  checkable "Done when ...": "every changed file accounted for", not
  "review done".
- **Gotchas**: facts about this environment that break a sensible
  assumption. These are the most valuable lines in a skill.
- **Template**: when the output has a fixed shape, show it, with a Bad and
  Good example for anything the agent tends to get wrong.
- **Report**: what the final message holds, and nothing else.

The steps above are a strong suggestion. If the skill design would benefit from more,
less, or different headings you may do so.

Keep `SKILL.md` under 500 lines if possible. Move reference material the skill might
need occasionally into a file beside it, and say when to read it: "Read
`guide.md` if drafting", not "see guide.md".

A script the agent would otherwise rewrite each run goes beside the skill.
Call it by its full path from home, `python3 -I
~/.claude/skills/<name>/<script>.py`, and list each output line it can end
on and what to do after it. `${CLAUDE_PLUGIN_ROOT}` is unset outside a
plugin.

## 4. Check

Read the draft once against each item:

- Every line passes "would the agent get this wrong without it?" Cut what
  doesn't.
- Nothing explains what the agent already knows (what git, HTTP or a
  migration is), or restates what a config file, `ls` or `--help` shows.
  Keep the unwritten convention and the reason behind it.
- The description stays on one line.
- the Skill has no comments explaining itself.
- Every path, command and flag exists. Run `--help` or `ls` on the ones
  you didn't just use.

## Report

```markdown
Wrote `<path>`.

Should trigger: "<prompt>", "<prompt>", "<prompt>"
Should not: "<near-miss prompt>", "<near-miss prompt>"

- Overlaps `<skill>`: <the boundary>.
- Not tracked by yadm: run `yadm add <path>` to keep it.
```

Include a bullet only when it applies. The near-miss prompts share words
with the skill but need something else; they test that the description is
precise.
