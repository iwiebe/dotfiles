#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Make brew available for the rest of this script (Apple Silicon default path).
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "==> Installing GNU Stow..."
brew install stow

echo "==> Backing up existing dotfiles..."
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Move aside real (non-symlink) files so stow can take over without conflicts.
for f in .zshrc .gitconfig; do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$BACKUP_DIR/$f"
    echo "Backed up ~/$f"
  fi
done

# ~/.ssh must already exist so stow only symlinks the `config` file, not the dir.
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ -f "$HOME/.ssh/config" ] && [ ! -L "$HOME/.ssh/config" ]; then
  mv "$HOME/.ssh/config" "$BACKUP_DIR/ssh_config"
  echo "Backed up ~/.ssh/config"
fi

echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"
# --no-folding keeps ~/.ssh and ~/.claude as real directories and only links
# files inside them. --ignore excludes Claude Code's settings.json: it's an
# app-mutated file (plugins.sh and the `claude` CLI rewrite it in place), so a
# symlink would push machine-generated plugin state back into the repo. We seed
# it as a plain copy below instead.
stow --no-folding --ignore='settings\.json' --target="$HOME" .

echo "==> Seeding Claude Code settings (only if absent)..."
# Seed the template on first run; never clobber a live settings.json, whose
# enabledPlugins/extraKnownMarketplaces are populated by plugins.sh afterwards.
mkdir -p "$HOME/.claude"
if [ ! -e "$HOME/.claude/settings.json" ]; then
  cp "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
  echo "Seeded ~/.claude/settings.json from template"
else
  echo "~/.claude/settings.json already exists — left untouched"
fi

echo "==> Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

echo "==> Installing global agent skills..."
# Non-fatal: a failing/unreachable skill repo shouldn't abort the whole setup.
"$DOTFILES_DIR/skills.sh" || echo "warning: some skills failed to install (see above)"

echo "==> Installing Claude Code plugins..."
"$DOTFILES_DIR/plugins.sh" || echo "warning: some plugins failed to install (see above)"

echo "==> Done! Originals (if any) backed up to $BACKUP_DIR"
