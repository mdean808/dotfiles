---
name: status
description: Show where the current work stands in ten lines. Use when the user asks where we are at, or for the status of the work.
allowed-tools:
  - Read
  - Bash(git status *)
  - Bash(git branch *)
  - Bash(git log *)
  - Bash(git rev-parse *)
  - Bash(glab mr view *)
  - Bash(glab issue view *)
  - Bash(ls *)
  - Bash(grep *)
  - Bash(find *)
  - ToolSearch
  - mcp__claude_ai_Linear__get_issue
  - mcp__claude_ai_Atlassian__getJiraIssue
---

# /status

Answer "where are we at" in ten lines or fewer, without changing anything.

## Rules

- Write nothing: no files, tracker or GitLab writes.
- Every line comes from a command or file read this run, never from memory
  of the conversation.
- A line with nothing to report says `none`.

## Steps

1. Branch: `git branch --show-current`. Take the ticket key from the branch
   name, matching the key or legacy key in the "Issue tracker" table in
   `CLAUDE.local.md`.
2. Ticket: find its directory in `.scratch/` as
   `~/.claude/rules/scratch-workflow.md` lays it out, and take the title and
   `status:` from the issue file or `ticket.md`. With no file, fetch the
   title and state from the tracker the table names: Linear `get_issue`,
   Jira `getJiraIssue`, GitLab `glab issue view <n>`. Load an MCP tool with
   ToolSearch first.
3. Slice: the first slice in the ticket's plan that is neither done nor
   blocked. A slice `changes.md` or `git log main..HEAD` shows as done counts
   as done.
4. Uncommitted: `git status --short`, as a count and the first few paths.
5. Tests: the MR pipeline's test jobs, or a run earlier in this session.
   Name the source, not how long ago it ran. Otherwise `no run found`. Never
   run tests to fill this line.
6. MR: `glab mr view` for state and pipeline, and
   `glab mr view --unresolved` for open review threads. Without an MR, say
   `no MR`.
7. Next: one concrete action, taken from the slice, then the review threads,
   then the uncommitted files.

## Template

```
Branch:      feat/<KEY>-<n>-<slug>
Ticket:      <KEY>-<n> <title> (<state>)
Slice:       <i> of <n> <name>
Uncommitted: <n> files (<path>, <path>, <path>)
Tests:       <suite> <n> passed, pipeline #<id>
MR:          !<iid> <state>, pipeline <status>, <n> unresolved threads
Next:        <action>
```

## Gotchas

- Older branches can carry the legacy key. Match either key.
- On `main`, or a branch with no key, the Ticket and Slice lines say `none`.
