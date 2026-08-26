# dotfiles

Personal macOS config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Everything targets `~`, so the repo layout mirrors the home directory:

```
~/dotfiles/
├── .zshrc                  # zsh config
├── .gitconfig              # git config
├── .ssh/config             # ssh client config (keys are NOT tracked)
├── .claude/
│   ├── settings.json       # Claude Code settings
│   └── statusline.sh       # Claude Code statusline (context % + rate limits)
├── Brewfile                # Homebrew formulae, casks, and taps
├── optional.sh             # interactive installer for optional day-two apps
├── bootstrap.sh            # one-shot machine setup
└── .gitignore
```

> Only `settings.json` and `statusline.sh` are tracked under `.claude/`. The rest
> of `~/.claude` (history, sessions, projects, caches) is machine-local and
> git-ignored. `statusline.sh` needs `jq` (in the `Brewfile`); to actually use it,
> `settings.json` must include a `statusLine` block pointing at
> `~/.claude/statusline.sh`.

## Set up a new machine

First: `xcode-select --install` (a fresh macOS has no `git`), and **sign into the
App Store** — the `Brewfile` includes a `mas` app, and `mas` can't first-acquire
an app the Apple ID has never "gotten". That failure aborts `brew bundle`, and
bootstrap runs under `set -e`, so skills and plugins never get installed.

```bash
git clone https://github.com/iwiebe/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

> Clone over **HTTPS**, not SSH. A new machine has no SSH key yet (keys are never
> tracked here), and the `url."https://github.com/".insteadOf` rewrite in
> `.gitconfig` that would redirect an SSH URL isn't installed until bootstrap
> stows it. The repo is public, so HTTPS needs no auth.

`bootstrap.sh` will:

1. Install Homebrew if it's missing.
2. Append the `brew shellenv` line to `~/.zprofile` if absent, so `brew` is on
   the PATH in new shells — `.zshrc` calls `brew --prefix` for `pure`'s `fpath`,
   and Homebrew's installer only prints that line rather than writing it.
3. Install GNU Stow.
4. Back up any existing real dotfiles to `~/.dotfiles_backup_<timestamp>/`.
5. Symlink everything into `~` with `stow --no-folding` (so `~/.ssh` stays a
   real directory and only `~/.ssh/config` is symlinked).
6. Seed `~/.claude/settings.json` from the template if it doesn't exist yet.
7. Install everything in the `Brewfile` via `brew bundle`.
8. Install global agent skills (`skills.sh`) and Claude Code plugins
   (`plugins.sh`) — both non-fatal.

Afterward, generate an SSH key (`ssh-keygen -t ed25519`) and add it to GitHub and
any hosts in `.ssh/config`; log into the `claude` CLI and re-run `plugins.sh` if
it was unauthenticated; then run `optional.sh` for day-two apps.

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

> **Note:** `brew bundle dump` records only top-level packages — the equivalent
> of `brew leaves` — not the dependencies they pull in. (On this machine that's
> ~10 entries out of ~41 installed formulae.) So the `Brewfile` stays a list of
> things you actually asked for, and Homebrew re-resolves dependencies at install
> time on the target machine.

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

## Agent skills

Global (user-level) [agent skills](https://github.com/vercel-labs/skills) are
declared in `Skillfile` — the Brewfile equivalent for skills — and installed by
`skills.sh`. `bootstrap.sh` runs it automatically after `brew bundle`.

```bash
~/dotfiles/skills.sh            # install everything in Skillfile (global)
~/dotfiles/skills.sh --list     # print the parsed list and exit
DRY_RUN=1 ~/dotfiles/skills.sh   # show the commands, install nothing
```

Add a skill by appending a line to `Skillfile`:

```
<package>  [skill-name]
```

`<package>` is a repo URL or `owner/repo`; the optional second field maps to
`skills add --skill <name>` to pick one skill from a multi-skill repo.

Notes:
- Skills install **globally** (`skills add -g`) so they apply in every project —
  that's why they belong in dotfiles. For skills you only want in one repo, run
  `npx skills add <pkg>` (no `-g`) there instead; that writes a project-level
  `skills-lock.json` you commit to *that* repo.
- Requires `npx` (Node), which the `Brewfile` installs (`node@24`).
- Installs are scoped to Claude Code only (`--agent claude-code`) to avoid the
  fan-out to ~70 agent tools and the "does not support global installation" noise
  from ones like PromptScript. Target others with, e.g.,
  `AGENTS=claude-code,zed ~/dotfiles/skills.sh`.

## Claude Code plugins

Some sources ship as full [Claude Code plugins](https://docs.claude.com/en/docs/claude-code/plugins)
(agents + commands + hooks + skills) and get invoked with a `plugin:skill`
namespace, avoiding the flat-`~/.claude/skills/` name collisions the plain
`skills` CLI is prone to. Those are declared in `Pluginfile` and installed by
`plugins.sh` (user scope). `bootstrap.sh` runs it after `skills.sh`.

```bash
~/dotfiles/plugins.sh            # add marketplaces, then install plugins
~/dotfiles/plugins.sh --list     # print the parsed list and exit
DRY_RUN=1 ~/dotfiles/plugins.sh   # show the commands, install nothing
```

`Pluginfile` lines:

```
marketplace <github-repo-or-url>   # register a marketplace
plugin       <name>@<marketplace>  # install a plugin from it
```

Notes:
- Needs the `claude` CLI (the `claude-code` cask in the `Brewfile`).
- Plugin installs clone over **SSH**. The `url."https://github.com/".insteadOf`
  rewrite in `.gitconfig` redirects github SSH → HTTPS so the clone succeeds
  without a `github.com` host key (our `~/.ssh/config` uses `UserKnownHostsFile
  /dev/null`, and the plugin installer forces strict host-key checking).
- Prefer a **plugin** over the flat `Skillfile` when a repo offers one and you
  want namespacing — e.g. `addyosmani/agent-skills` lives here, not in `Skillfile`.

## Optional / day-two apps

Core apps live in the `Brewfile` and install automatically during bootstrap.
Situational or heavy apps (Xcode, ProPresenter, etc.) are kept out of the core
install and handled by `optional.sh`, which shows a menu so you can install just
the ones you want on a given machine — no need to remember install commands:

```bash
~/dotfiles/optional.sh          # menu: pick numbers (e.g. "1 3 5"), or "a" for all
~/dotfiles/optional.sh --all    # install everything, no prompt
~/dotfiles/optional.sh --list   # print the catalog and exit
DRY_RUN=1 ~/dotfiles/optional.sh --all   # show what would run, install nothing
```

To add an app, append one line to the `APPS` list at the top of `optional.sh`
(`cask|<cask-name>|<label>` for casks, `mas|<id>|<label>` for App Store apps).

**Xcode notes:** it's installed via `mas`, so you must be signed into the App
Store and have "gotten" Xcode under that Apple ID at least once — `mas` can't
first-acquire apps. After it installs, finish setup with:

```bash
sudo xcodebuild -license accept
sudo xcode-select -s /Applications/Xcode.app
xcodebuild -runFirstLaunch
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
