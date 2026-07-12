#!/usr/bin/env bash
# skills.sh — install the global agent skills listed in ./Skillfile.
#
# Usage:
#   ./skills.sh            # install everything in Skillfile (global / user-level)
#   ./skills.sh --list     # print the parsed skill list and exit
#   DRY_RUN=1 ./skills.sh   # print the commands instead of running them
#
# Skills are installed globally (`skills add -g`) so they apply across every
# project — that's why they live in dotfiles. Uses `npx skills`, so Node/npx
# (from the Brewfile's node@24) must be present; bootstrap.sh installs that first.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLFILE="$DIR/Skillfile"

# Agents to install skills into (comma-separated). Scoping avoids fanning out to
# ~70 agent tools and the "does not support global installation" noise from ones
# like PromptScript. Override, e.g.:  AGENTS=claude-code,zed ./skills.sh
AGENTS="${AGENTS:-claude-code}"

[ -f "$SKILLFILE" ] || { echo "No Skillfile at $SKILLFILE" >&2; exit 1; }
command -v npx >/dev/null 2>&1 || {
  echo "npx (Node.js) not found — run bootstrap.sh first." >&2
  exit 1
}

run() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "    [dry-run] $*"
  else
    "$@"
  fi
}

# Each line: first field = package, optional second field = skill name.
# `read` splits on whitespace; `_` swallows any trailing inline comment.
# Read the Skillfile on FD 3, not stdin — otherwise `npx skills` inherits our
# stdin and eats the remaining lines (and can't prompt interactively).
while read -r pkg skill _ <&3 || [ -n "$pkg" ]; do
  case "$pkg" in
    ''|\#*) continue ;;   # blank line or full-line comment
  esac
  # A '#' landing in the skill field means there was no real skill name.
  case "$skill" in
    \#*) skill="" ;;
  esac

  if [ "${1:-}" = "--list" ]; then
    printf "  %s%s\n" "$pkg" "${skill:+  (skill: $skill)}"
    continue
  fi

  if [ -n "$skill" ]; then
    echo "==> $pkg  --skill $skill  (agents: $AGENTS)"
    run npx --yes skills add -g "$pkg" --skill "$skill" --agent "$AGENTS" -y
  else
    echo "==> $pkg  (agents: $AGENTS)"
    run npx --yes skills add -g "$pkg" --agent "$AGENTS" -y
  fi
done 3< "$SKILLFILE"

[ "${1:-}" = "--list" ] || echo "==> Done."
