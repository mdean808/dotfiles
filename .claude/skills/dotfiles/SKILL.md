---
name: dotfiles
description: Track dotfiles with yadm, then pull, commit every change and push. Use when the user asks to add something to yadm, or to commit, sync or push to yadm.
---

# dotfiles

Pull, track any new file and wire it into the bootstrap so a fresh machine
reproduces it, then commit every change to tracked files and push. A request
to commit to yadm includes the pull and the push.

## Rules

- Commit every change to tracked files, not only the ones this session made.
  Stage them with `yadm add -u`.
- Never `yadm add -A` or `.`. `$HOME` holds hundreds of untracked files. Add
  untracked files only by explicit path, and only the ones the user asked to
  track or that a bootstrap edit needs.
- Never add secrets or machine-local files: `~/.claude/settings.local.json`,
  `~/.claude/.credentials.json`, `~/.wakatime.cfg`, `~/.ssh`, shell history.
  A file that differs per machine becomes a `##class.<name>` or
  `##distro.<name>` alternate, as `.gitconfig` does. If a tracked file's diff
  adds a secret, stop and ask.
- Never amend, force-push or pass `--no-verify`. If the push is rejected,
  pull again and retry once, then stop and report.

## Steps

1. Pull: `yadm pull --autostash`. If it conflicts, follow
   [Conflicts](#conflicts) before going on.
2. Find what new file to track, if any, from the arguments or the
   conversation. `yadm ls-files <path>` shows whether a file is tracked.
3. Wire it into the bootstrap when it needs a program, a service, or a
   setting applied.
   - Read `~/.config/yadm/CLAUDE.md` first. It describes the bootstrap
     files, how steps are written, the package lists and which machine
     classes run what.
   - A file that must be reapplied on every pull also gets a step in
     `.config/yadm/hooks/post_pull`.
4. `yadm add` the new file and every untracked helper the bootstrap edits
   source. Then `yadm add -u`.
5. Run `yadm commit -m` with a message that covers all staged changes.
6. `yadm push`. Done when the push succeeds and `yadm status -sb` shows the
   branch up to date with no modified tracked files.

## Conflicts

A conflict comes from the rebase of unpushed commits, or from the autostash
reapplying local changes (`yadm stash list` then still holds the entry).

1. List the files: `yadm diff --name-only --diff-filter=U`.
2. Resolve a file yourself when both sides changed different things that
   can coexist. `yadm add` it.
3. Ask the user when:
   - both sides changed the same setting or line to different values,
   - one side deleted or renamed a file the other changed,
   - the file is binary or generated,
   - you can't tell which side is meant to win.
4. Finish the rebase with `yadm rebase --continue`. After an autostash
   conflict, `yadm stash drop` once every file is resolved.
5. Before going on, `yadm diff --check` shows no markers left.

If the user wants to abandon the pull, `yadm rebase --abort` and stop.

## Gotchas

- `yadm status` hides untracked files. List them with
  `yadm ls-files -o --exclude-standard <dir>`.
- `.config/yadm/bootstrap` is a symlink yadm generates for this machine.
  Edit the `bootstrap##...` file it points at.
- `yadm pull` and `yadm push` run the hooks in `.config/yadm/hooks/`.
  Their output is expected.
