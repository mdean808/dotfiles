---
name: dotfiles
description: Track dotfiles with yadm and push them. Use when the user asks to add something to yadm, or to commit or push to yadm.
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
---

# /dotfiles

Track the file with yadm, wire it into the bootstrap so a fresh machine
reproduces it, then commit and push. A request to commit to yadm includes the
push.

## Rules

- Never `yadm add -A`, `-u` or `.`. `$HOME` holds hundreds of untracked files
  and unfinished edits. Add and commit by explicit path.
- Never add secrets or machine-local files: `~/.claude/settings.local.json`,
  `~/.claude/.credentials.json`, `~/.wakatime.cfg`, `~/.ssh`, shell history.
  A file that differs per machine becomes a `##class.<name>` or
  `##distro.<name>` alternate, as `.gitconfig` does.
- Pass paths to `yadm commit`, so changes the user left staged or modified
  elsewhere stay out.
- Never amend, force-push or pass `--no-verify`. If the push is rejected,
  stop and report.

## Steps

1. Find what to track from the arguments or the conversation.
   `yadm ls-files <path>` shows whether a file is tracked.
2. Wire it into the bootstrap when it needs a program, a service, a system
   path or a setting applied. A plain config that a tracked program already
   reads needs only the add.
   - Define `step_<name>` so it returns early when already done. Bootstrap
     reruns, under `set -e`.
   - Both distros: `.config/yadm/bootstrap.common`, plus `run <name>` in
     `common_steps`.
   - Debian or Ubuntu only: `.config/yadm/bootstrap.debian`, plus
     `run <name>` in `.config/yadm/bootstrap##distro_family.debian`.
   - Arch only: `.config/yadm/bootstrap##distro.arch`. A package goes in the
     `pacman` list in its `step_packages`.
   - Packages: the apt list in `bootstrap.debian` and the pacman list in the
     arch file, each under that distro's package name.
   - Also needed on the headless server: `run <name>` in
     `.config/yadm/bootstrap##class.headless,distro_family.debian`. Its
     `step_packages` has its own apt list.
   - A file copied into place on every pull, like `keyd-sync.sh`, also gets
     a call in `.config/yadm/hooks/post_pull`.
   - Done when the name is in the run list of every bootstrap that should
     install it, and `sh -n` passes on each edited script.
3. `yadm add` the file and every bootstrap, hook or script you edited,
   including untracked helpers they source.
4. Read `yadm log --oneline -10` for the message style: imperative, no
   ticket key, about what changed. Run `yadm commit <paths> -m` with the
   paths from step 3. End the message with the session's attribution lines,
   if it gives any.
5. `yadm push`. Done when the push succeeds and `yadm status -sb` shows the
   branch up to date.

## Gotchas

- `yadm status` hides untracked files. List them with
  `yadm ls-files -o --exclude-standard <dir>`.
- `.config/yadm/bootstrap` is a symlink yadm generates for this machine.
  Edit the `bootstrap##...` file it points at.
- `~/.claude/.gitignore` ignores everything except `skills/**`, `agents/**`,
  `rules/**`, `bin/**`, `commands/**`, `hooks/**`, `output-styles/**`,
  `CLAUDE.md`, `settings.json` and `keybindings.json`. A new file elsewhere
  under `~/.claude/` needs a `!` line there first. Skills still need an
  explicit `yadm add`.
- `yadm push` runs `post_push`, which commits and pushes `~/.config/nvim`
  and `~/.scratch`. Their output is expected.

## Report

- Files added, and the bootstraps each went into (Ubuntu, Arch, headless),
  or why none.
- Files skipped, including other changes left out of the commit, and why.
- Commit hash and the push result.
