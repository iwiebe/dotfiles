# dotfiles

Personal macOS config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Everything targets `~`, so the repo layout mirrors the home directory:

```
~/dotfiles/
├── .zshrc          # zsh config
├── .gitconfig      # git config
├── .ssh/config     # ssh client config (keys are NOT tracked)
├── Brewfile        # Homebrew formulae, casks, and taps
├── bootstrap.sh    # one-shot machine setup
└── .gitignore
```

## Set up a new machine

```bash
git clone git@github.com:iwiebe/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` will:

1. Install Homebrew if it's missing.
2. Install GNU Stow.
3. Back up any existing real dotfiles to `~/.dotfiles_backup_<timestamp>/`.
4. Symlink everything into `~` with `stow --no-folding` (so `~/.ssh` stays a
   real directory and only `~/.ssh/config` is symlinked).
5. Install everything in the `Brewfile` via `brew bundle`.

### Git-free install

Don't have (or want) Git on the new machine? Download the repo as a tarball
straight into `~/dotfiles`, then run bootstrap. Because the files are stowed
into `~` (not extracted there directly), keep the whole tree intact — including
`bootstrap.sh` and the `Brewfile`:

```bash
mkdir -p ~/dotfiles
curl -#L https://github.com/iwiebe/dotfiles/tarball/main \
  | tar -xzv -C ~/dotfiles --strip-components 1 --exclude={README.md,.gitignore}
~/dotfiles/bootstrap.sh
```

Note this gives you a plain directory with no `.git`, so you can't `git pull`
updates later. To re-sync, re-run the command above (it overwrites the files),
or install Git and `git clone` as shown above for a proper working copy.

## Day-to-day

Because the files in `~` are symlinks back into this repo, editing e.g.
`~/.zshrc` edits `~/dotfiles/.zshrc`. To save changes:

```bash
cd ~/dotfiles
git add -A
git commit -m "Update zshrc"
git push
```

To pull changes onto another machine:

```bash
cd ~/dotfiles && git pull
```

## Updating the Brewfile

The `Brewfile` is a snapshot of installed Homebrew packages. It does **not**
update itself — regenerate it whenever you install or remove something you want
to keep.

### Regenerate from what's currently installed

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
```

`--force` overwrites the existing file. Review the diff before committing:

```bash
cd ~/dotfiles
git diff Brewfile
git add Brewfile
git commit -m "Update Brewfile"
git push
```

> **Note:** `brew bundle dump` records *everything* Homebrew currently knows
> about — including packages pulled in as dependencies. That's expected; it
> makes the Brewfile a faithful snapshot of the machine.

### Install the Brewfile on another machine

```bash
brew bundle install --file=~/dotfiles/Brewfile
```

### Prune packages no longer in the Brewfile

To uninstall anything on the machine that is **not** listed in the Brewfile
(dry-run first, it's destructive):

```bash
brew bundle cleanup --file=~/dotfiles/Brewfile        # preview
brew bundle cleanup --file=~/dotfiles/Brewfile --force # actually remove
```

## Adding a new dotfile

1. Move the real file into the repo, preserving its path relative to `~`:
   ```bash
   mv ~/.someconfig ~/dotfiles/.someconfig
   ```
2. Re-stow to create the symlink:
   ```bash
   cd ~/dotfiles && stow --no-folding --target="$HOME" .
   ```
3. Commit it.

## Security

- Private SSH keys are never committed — `.gitignore` blocks `.ssh/id_*`,
  `*.pem`, `known_hosts*`, and `authorized_keys`. Only `.ssh/config` is tracked.
- `.ssh/config` references internal host/IP patterns. If that's sensitive,
  keep the GitHub repo **private**.
