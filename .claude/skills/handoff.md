# Handoff: Cost-optimised fork of Matt Pocock's agent workflow

## Goal

Fork Matt Pocock's skills (https://github.com/mattpocock/skills) into my own workflow, with one priority: **minimise usage and token cost while keeping output correct.** Speed doesn't matter. Wherever a choice trades tokens for wall-clock time, take the cheaper option.

Core design: Opus 5.5 (expensive, stronger judgment) handles thinking and review. Sonnet 5.5 (about half the per-token price, within a few points of Opus on most benchmarks) handles well-scoped implementation and iteration.

## Environment

- I use **T3 Code**, which runs the Claude Code provider, in auto mode.
- T3 Code locks the model per thread (the provider can't change once a thread starts). Plans can be implemented across threads.
- Skills live in `.claude/skills/<name>/SKILL.md`. Keep the layout **flat**: grouping folders like `.claude/skills/group/skill/` aren't documented to work. Use name prefixes, or a plugin, to group skills.

## Target pipeline (root thread on Opus)

```
$grill-with-docs   Opus root (inline)
$to-tickets        Opus root (inline)
$implement         spawns ONE Sonnet sub-agent that completes all tickets sequentially
$feedback          inline Sonnet (skill `model: sonnet`, no fork), my UI/iteration feedback
$code-review       spawns Opus sub-agent(s)
```

## Skills being forked or created

`domain-modeling`, `feedback` (new), `grilling`, `implement`, `start-ticket` (new or adapted), `to-tickets`, `code-review`, `grill-with-docs`, `handoff`, `to-spec`.

## Decisions so far

1. **Model selection lives in skill frontmatter.** None of Pocock's skills set a model.
   - `model: opus` / `model: sonnet` **without** `context: fork` overrides the model for the current turn only. The session model resumes on the next prompt.
   - With `context: fork` (plus `agent:` and optionally `background: false`), the skill runs as a sub-agent on that model. **A forked sub-agent can't see the conversation history**, so everything it needs has to be in the tickets or files it reads.
   - The docs say auto mode ignores models it doesn't support. Confirm Opus 5.5 and Sonnet 5.5 overrides actually take effect in T3 Code auto mode.
   - Not yet verified that T3 Code honours skill `model` / `context: fork`. Test with one skill first.

2. **Drop `to-spec` from the main path.** I've found specs too rigid: the reviewing agent flags things I intended to iterate on, especially UI. `to-tickets` already works from "a plan, spec, or the current conversation", and `implement` works from "spec or tickets". Keep `to-spec` forked but optional, for larger work only.

3. **`to-tickets` edits** (base: upstream `skills/engineering/to-tickets/SKILL.md`):
   - Add a **Context** section after "What to build" in both the local and issue templates: the grill decisions this ticket depends on (chosen approach, rejected alternatives, constraints). The Sonnet implementer won't see the conversation.
   - Add a vertical-slice rule: for UI work, acceptance criteria cover **behaviour only**. Visual details (spacing, styling) get iterated after implementation and aren't criteria.

4. **`implement`: one Sonnet sub, sequential.**
   - Upstream `implement` doesn't specify sequential or parallel. Upstream `implement-spec` runs one fresh sub per ticket in parallel worktrees, which is fast but token-heavy, so **don't use that pattern.**
   - A single sub reuses codebase reading and prompt cache across tickets. Start a fresh sub only if its context gets very large.
   - **Upstream `implement` calls `code-review` at the end.** Remove that call, or review runs on Sonnet and then again on Opus.
   - Upstream `implement` also calls `tdd` at pre-agreed seams. Keep that.

5. **`feedback` (new): inline, not forked.** My feedback rounds are concrete UI asks, e.g. "use this component on these two pages, fix padding/styling to match the site, fix this bug". A fresh sub per round re-reads files with no cache benefit, so run it inline with `model: sonnet` to keep history and cache. Hand it the whole feedback message in one go. Escalate to Opus only when the feedback is architectural or ambiguous.

6. **`code-review`: Opus.**
   - Upstream launches two fresh sub-agents in parallel, Standards and Spec. Give it `model: opus`, or `inherit` from the Opus root.
   - It looks for a spec via commit issue refs, a path argument, or `docs/` / `specs/` / `.scratch/`. With no spec it skips the Spec sub-agent and reports "no spec available". **Pass the tickets folder or parent issue as the argument** so it reviews against the tickets.
   - Run it at Medium effort, and only on meaningful changes. Small UI rounds can skip it.

7. **Effort level matters more than model choice.** Artificial Analysis figures, as quoted by secondary sources and not yet verified, put Sonnet 5.5 at about $0.35 per task on Low and $5.46 on Max. Default to High, or Medium for small tickets. Avoid Xhigh/Max unless needed.

## Open items

- Check that T3 Code passes skill `model` / `context: fork` through, and that the overrides work in auto mode.
- Define `start-ticket`'s role. Possibly the per-ticket entry point the Sonnet implementer uses: read the ticket and its Context, then implement.
- Decide which `code-review` sub-agents actually need Opus. Running both at Opus doubles the review cost.

## Reference

- Upstream skills: https://github.com/mattpocock/skills (`skills/engineering/*`, `skills/productivity/*`)
- Claude Code skills docs: https://code.claude.com/docs/en/skills
- Claude Code sub-agents docs: https://code.claude.com/docs/en/sub-agents
- Routing background (optional reading): RouteLLM (arXiv 2406.18665), TwinRouterBench (arXiv 2605.18859), LLMRouterBench (arXiv 2601.07206)

## Suggested skills

- `skill-creator`, for editing and forking each SKILL.md
- `writing-for-agents` (upstream), when rewriting skill prompts
- `to-tickets`, `implement`, `code-review` (upstream versions), read them as the base for each fork

## Instructions for the next agent

You're helping fork Matt Pocock's workflow for my own use under the considerations above. Optimise for **cost and tokens, not speed**, without compromising correctness. Base each forked skill on the current upstream SKILL.md. Change only what these decisions require. Keep skills flat under `.claude/skills/`. Don't build anything I haven't asked for. Propose each skill change and let me apply it.
