---
name: report
description: Write up findings you already have as a short report. Use when the user asks for a report or write-up of findings, not for new research.
allowed-tools:
  - Read
  - Write
  - Bash(ls *)
---

# /report

Write findings as a report that answers the question and nothing else.
`mattpocock-skills:research` gathers and cites the facts. This skill sets the
shape of the report written from them.

## Rules

- Write only the report file. Don't re-run experiments to write it.
- The reader knows the question, not the work.
- Size it to the question. One question gets one answer, usually under a
  page. If the user says it is too long, cut material, not formatting.

## Steps

1. Restate the question in one line. If the findings don't answer it, the
   answer says so and names what is missing.
2. Write to `report.md` in the ticket or feature's `.scratch/` directory,
   found as `~/.claude/rules/scratch-workflow.md` says, or a new
   `.scratch/<feature-slug>/`. If a report exists, write
   `report-v2.md` and so on, and leave the old one.
3. Fill the template. Done when every number in the answer is in the table.
4. Reply with the answer in one or two lines and the path. Never repeat the
   report.

## Template

```markdown
# <Question as a question>

**Answer:** <the direct answer, with the number or yes/no>

## Evidence
| Case | Result | Source |
|---|---|---|

## Assumptions
- <value or condition the answer depends on>

## Terms
- **<term>**: <plain definition>
```

- Evidence holds measured cases named as the user knows them, such as real
  file sizes and inputs.
- Assumptions list the settings the numbers depend on, such as a memory
  limit or flags. Skip any you didn't rely on.
- Terms lists only words the reader may not know. Drop the section if none.
- Leave out how to re-run, the history of attempts, the method and next
  steps unless asked. Re-run instructions belong in the repo.

```markdown
Bad:  Run `bench.sh` to reproduce. See README for setup.
Good: (no such line)
```
