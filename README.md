# .dotfiles

Personal macOS dotfiles, managed with per-app symlinks into `~/.config`.

## Install

```bash
/bin/bash -c "$(curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/afoures/.dotfiles/HEAD/setup.sh)"
```

This bootstraps a fresh machine. `setup.sh`:

1. Installs the Xcode command-line tools.
2. Generates an ED25519 SSH key and writes a `github.com` entry to `~/.ssh/config` (copies the public key to your clipboard — **add it to GitHub when prompted**).
3. Clones this repo to `~/code/.dotfiles` (and inits submodules, e.g. tpm).
4. Backs up your existing config (see [Backups](#backups)).
5. Installs Homebrew and runs `brew bundle` against `brew/default-setup`, optionally cleaning up packages not listed.
6. Symlinks each dir in `config/` to `~/.config/<name>` and `~/.zshenv`.
7. Applies macOS system defaults (Dock, Finder, Safari, keyboard, etc.).

> Requires Full Disk Access for your terminal so the `defaults write` step works.

## Layout

```
config/      app configs, each symlinked to ~/.config/<name>
brew/        brewfiles (default-setup is the baseline; add more per use case)
bin/         helper scripts (on PATH via .zshenv)
setup.sh     one-shot machine bootstrap
backup.sh    snapshots existing config before changes
```

`bin/` helpers: `sync-dotfiles` (pull + re-link + reload), `adopt` (move a local
config into the repo and symlink it back), `switch-session`, `switch-nvim-config`.

## Syncing changes

After committing config changes, pull them onto a machine with:

```bash
sync-dotfiles            # interactive
sync-dotfiles --quiet    # for background/cron use
```

It fetches `origin/main`, refuses to pull on conflicts, updates symlinks for
changed configs (backing up anything in the way), runs `brew bundle` if the
brewfile changed, and reloads tmux automatically.

## Brewfiles

`brew/default-setup` is the baseline package set. Add more brewfiles for
non-default setups and install them on demand:

```bash
brew bundle --file=brew/<name>
```

Note: `brew bundle cleanup` is **per-file** — running it against
`default-setup` will flag packages from any other brewfile for removal.

## Backups

Existing config is snapshotted to `.backups/backup_<epoch>/` before being
replaced (by `setup.sh` and by `sync-dotfiles` when it swaps in a symlink).
Snapshots are never deleted automatically; once more than 10 pile up you'll
get a reminder to prune. To prune manually:

```bash
rm -rf .dotfiles/.backups/backup_*   # remove all snapshots
```
