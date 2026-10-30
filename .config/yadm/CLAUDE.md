# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## What this is

The yadm config directory for dotfiles tracked from `$HOME`. It is not a git
repo itself: the repo is `~/.local/share/yadm/repo.git` and its work tree is
`$HOME`. Use `yadm` in place of `git` (`yadm status`, `yadm ls-files`,
`yadm log`). To track, commit or push files, use the `/dotfiles` skill
(`~/.claude/skills/dotfiles/SKILL.md`); it holds the add, commit and push
rules.

## Checking scripts

Everything is POSIX `sh`. No shellcheck or shfmt is installed. Check an
edited script with `sh -n <file>`. Running a bootstrap installs packages
with `sudo`, so don't run one to test it.

## Bootstrap layout

yadm picks an alternate by suffix and symlinks `bootstrap` to the one that
matches this machine. Edit the `bootstrap##...` file, never the symlink.

| File | Role |
| --- | --- |
| `lib.sh` | Runner and output styling, shared with the hooks |
| `bootstrap.common` | Sources `lib.sh`; shared `step_*`, `common_steps` |
| `bootstrap.debian` | Debian/Ubuntu `step_*` and `apt_install` |
| `bootstrap##distro_family.debian` | Ubuntu desktop run list |
| `bootstrap##distro_family.arch` | Arch run list and its own pacman list |
| `bootstrap##class.headless,distro_family.debian` | Headless server |

- `run <name> '<what it does>' [needs...]` runs `step_<name>` in a
  `set -e` subshell and prints one line: `✓` done, dim `✓` already done,
  `–` skipped, `○` not for this machine, `✗` failed. Step output streams
  under a `│` gutter; a step with no output collapses to its result line.
  A failed step doesn't stop the run. A step whose `needs` didn't finish
  is skipped. `finish` prints counts, failures, skips and the to-do list,
  and exits 1 if any step failed.
- Inside a step: `already '<why>'` ends it as already done, `skip '<why>'`
  ends it as skipped, `fail '<why>'` fails it with a reason, `stop '<why>'`
  fails it and ends the whole run, `note '<text>'` adds detail to a done
  line, `todo '<text>'` adds a to-do item, and `ask '<prompt>'` reads
  `$_answer` from the terminal. Every step must call `already` when there
  is nothing to do, so a rerun reads as all done.
- Color only when stdout is a terminal and `NO_COLOR` is unset. In a
  terminal, the bootstrap asks for the sudo password once up front.
- `desktop_only` wraps `run` and skips the step on `headless`.
  `work_only` wraps `run` and skips it unless the class is `work`.
- `step_ssh` checks SSH access to GitHub, and to GitLab on `work`. In a
  terminal it offers to create a key and waits while you add it.
  `nvim_remote` and `scratch` need it.
- A step for every machine goes in `bootstrap.common` with a `run` line in
  `common_steps`. A Debian-only step goes in `bootstrap.debian`, with a
  `run` line in each Debian bootstrap that needs it. An Arch-only step goes
  in the Arch file.
- Packages: the apt list in `bootstrap.debian`'s `step_packages`, the
  headless file's own apt list, and the pacman list in the Arch file.
- A distro file sources `bootstrap.common` (and `bootstrap.debian`), may
  override a step such as `step_packages` or `manual_steps`, runs its own
  steps, then ends with `common_steps`. `manual_steps` adds items with
  `todo`.
- Each bootstrap sets `yadm sparse-checkout` to drop files that don't apply
  to that machine class. On headless, `keybindings.sh`, `keyd-sync.sh` and
  `workspaces.sh` are tracked but absent from disk.
- The headless sparse list excludes the Arch bootstrap, but this machine's
  sparse-checkout predates that rule on purpose: the Arch bootstrap is
  written here until an Arch machine exists. Don't rerun `step_sparse` here.

## Machine classes

`yadm config --get-all local.class` lists the classes (this machine:
`headless`, `personal`). The bootstrap and hooks check for `headless` to
skip desktop work, and for `work` to run scratch.

## Hooks and scratch

The hooks source `lib.sh` and print the same step lines as the bootstrap.

- `hooks/post_pull`: on desktops, runs `keyd-sync.sh`, `keybindings.sh` and
  `workspaces.sh` if present; pulls `~/.config/nvim`; on `work`, runs
  `scratch.sh pull`.
- `hooks/post_push`: commits and pushes `~/.config/nvim` (only if its origin
  is `mdean808/nvim-config`), listing the files it commits; on `work`, runs
  `scratch.sh push`.
- `scratch.sh` clones `git@gitlab.com:modean/scratch.git` into `~/.scratch`,
  links `scratch-sync` into `~/.local/bin`, and passes its arguments to it.
- Hooks and `scratch.sh` unset `GIT_DIR`, `GIT_WORK_TREE` and
  `GIT_INDEX_FILE` first, since yadm exports them and they would point the
  nested git calls at the yadm repo.
