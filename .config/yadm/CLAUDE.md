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
| `bootstrap.common` | `have`, `run`, shared `step_*` and `common_steps` |
| `bootstrap.debian` | Debian/Ubuntu `step_*` (apt repos, packages, fd) |
| `bootstrap##distro_family.debian` | Ubuntu desktop run list |
| `bootstrap##distro_family.arch` | Arch run list and its own pacman list |
| `bootstrap##class.headless,distro_family.debian` | Headless server |

- `run <name>` prints a header and calls `step_<name>`. Every step must
  return early when already done: bootstraps rerun under `set -e`.
- A distro file sources `bootstrap.common` (and `bootstrap.debian`), may
  override a step such as `step_packages` or `manual_steps`, then ends with
  `common_steps`.
- The headless file does not call `common_steps`. It inlines its own run
  list and skips desktop and scratch steps (keyd, fonts, `scratch`). A shared
  step it needs must be added to its list by hand.
- Each bootstrap sets `yadm sparse-checkout` to drop files that don't apply
  to that machine class. On headless, `keybindings.sh`, `keyd-sync.sh` and
  `workspaces.sh` are tracked but absent from disk.
- The headless sparse list excludes the Arch bootstrap, but this machine's
  sparse-checkout predates that rule on purpose: the Arch bootstrap is
  written here until an Arch machine exists. Don't rerun `step_sparse` here.

## Machine classes

`yadm config --get-all local.class` lists the classes (this machine:
`headless`, `personal`). The hooks check for `headless` to skip desktop work.

## Hooks and scratch

- `hooks/post_pull`: on desktops, runs `keyd-sync.sh`, `keybindings.sh` and
  `workspaces.sh` if present; pulls `~/.config/nvim`; on desktops, runs
  `scratch.sh pull`.
- `hooks/post_push`: commits and pushes `~/.config/nvim` (only if its origin
  is `mdean808/nvim-config`); on desktops, runs `scratch.sh push`.
- `scratch.sh` clones `git@gitlab.com:modean/scratch.git` into `~/.scratch`,
  links `scratch-sync` into `~/.local/bin`, and passes its arguments to it.
- Hooks and `scratch.sh` unset `GIT_DIR`, `GIT_WORK_TREE` and
  `GIT_INDEX_FILE` first, since yadm exports them and they would point the
  nested git calls at the yadm repo.
