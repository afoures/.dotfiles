# .dotfiles

Personal macOS dotfiles, managed with per-app symlinks into `~/.config`.

## Install

```bash
/bin/bash -c "$(curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/afoures/.dotfiles/HEAD/setup.sh)"
```

This bootstraps a fresh machine. `setup.sh`:

1. Installs the Xcode command-line tools.
2. Generates an ED25519 SSH key **protected by a passphrase** (you'll be asked to
   choose one; it's saved in the macOS keychain so you only type it once) and
   writes a `github.com` entry to `~/.ssh/config`. The public key is copied to
   your clipboard — **add it to GitHub when prompted**.
3. Clones this repo to `~/code/.dotfiles` (and inits submodules, e.g. tpm).
4. Backs up your existing config (see [Backups](#backups)).
5. Installs Homebrew and runs `brew bundle` against `brew/default-setup`, optionally cleaning up packages not listed.
6. Symlinks each dir in `config/` to `~/.config/<name>` and `~/.zshenv`.
7. Installs [mise](https://mise.jdx.dev) with its standalone installer (into
   `~/.local/bin`, not via brew) and runs `mise install` for the tools pinned in
   `config/mise/config.toml` (node, pnpm, …).
8. Installs fonts from the `afoures/fonts` repo.
9. Applies macOS system defaults (Dock, Finder, Safari, keyboard, etc.).

> Requires Full Disk Access for your terminal so the `defaults write` step works.

On an already-set-up machine you can re-run a single part instead of the whole
bootstrap by passing a command:

```bash
bash setup.sh fonts      # reinstall fonts only
bash setup.sh macos      # re-apply macOS defaults
bash setup.sh brew       # re-run brew bundle
bash setup.sh mise       # install mise + pinned tools
bash setup.sh symlinks   # re-link configs
bash setup.sh help       # list commands
```

## Shell

zsh, configured in `config/zsh` (`~/.zshenv` points `ZDOTDIR` there). Besides
the custom prompt, it wires up:

- **mise** — runtime versions (`mise activate zsh`), skipped if not installed.
- **fzf** — `ctrl-r` history search, `ctrl-t` file picker, `alt-c` cd into a dir.
- **zsh-autosuggestions** — grey inline suggestion from history; `→` accepts it,
  `alt-f` accepts one word.
- **zsh-syntax-highlighting** — colors the command line as you type (unknown
  commands in red, strings, paths, matching brackets).
- **emacs keybindings** (`ctrl-a`/`ctrl-e`, `alt-b`/`alt-f`, …), set explicitly
  because zsh would otherwise pick vi mode from `EDITOR=nvim`.
- **zsh-completions** — extra completion definitions from brew. Add your own
  with e.g. `talosctl completion zsh > $ZDOTDIR/.zfunc/_talosctl`.

Completions are cached in `~/.cache/zsh/.zcompdump` and not re-scanned on
startup; after installing new ones, `rm ~/.cache/zsh/.zcompdump && reload`.

Machine-local, untracked additions go in `config/zsh/.zshrc.local`.

## Layout

```
config/      app configs, each symlinked to ~/.config/<name>
brew/        brewfiles (default-setup is the baseline; add more per use case)
bin/         helper scripts (on PATH via .zshenv)
setup.sh     one-shot machine bootstrap
backup.sh    snapshots existing config before changes
```

`bin/` helpers: `sync-dotfiles` (pull + re-link + reload), `adopt` (move a local
config into the repo and symlink it back), `forget` (the reverse: move a config
back to `~/.config` as a plain directory and stop tracking it; `zsh`, `git` and
`nvim` can't be forgotten), `switch-session`, `switch-nvim-config`.

## Syncing changes

After committing config changes, pull them onto a machine with:

```bash
sync-dotfiles            # interactive
sync-dotfiles --quiet    # for background/cron use
```

It fetches `origin/main`, refuses to pull on conflicts, updates symlinks for
changed configs (backing up anything in the way), runs `brew bundle` if the
brewfile changed, and reloads tmux automatically. Configs that were `forget`-ten
on another machine are restored to `~/.config/<name>` as plain directories, so
every machine keeps its copy.

## Brewfiles

`brew/default-setup` is the baseline package set. Language runtimes are not in
it — they're managed by mise. Add more brewfiles for
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
