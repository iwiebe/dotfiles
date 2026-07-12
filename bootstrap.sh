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
# --no-folding keeps ~/.ssh as a real directory and only links files inside it.
stow --no-folding --target="$HOME" .

echo "==> Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

echo "==> Done! Originals (if any) backed up to $BACKUP_DIR"
