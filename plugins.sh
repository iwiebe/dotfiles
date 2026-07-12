#!/usr/bin/env bash
# plugins.sh — install the Claude Code plugins listed in ./Pluginfile (user scope).
#
# Usage:
#   ./plugins.sh          # add marketplaces, then install plugins
#   ./plugins.sh --list   # print the parsed marketplaces/plugins and exit
#   DRY_RUN=1 ./plugins.sh   # print the commands instead of running them
#
# Needs the `claude` CLI (claude-code cask in the Brewfile). Plugin installs
# clone over SSH; the url."https://github.com/".insteadOf rewrite in .gitconfig
# redirects github SSH -> HTTPS so the clone works without a known host key.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINFILE="$DIR/Pluginfile"

[ -f "$PLUGINFILE" ] || { echo "No Pluginfile at $PLUGINFILE" >&2; exit 1; }
command -v claude >/dev/null 2>&1 || {
  echo "claude CLI not found — install the claude-code cask (Brewfile) first." >&2
  exit 1
}

run() {
  if [ "${DRY_RUN:-0}" = "1" ]; then echo "    [dry-run] $*"; else "$@"; fi
}

# --list: just echo the parsed entries. Read on FD 3 so child procs keep stdin.
if [ "${1:-}" = "--list" ]; then
  while read -r kind arg _ <&3 || [ -n "$kind" ]; do
    case "$kind" in ''|\#*) continue ;; esac
    printf "  %-11s %s\n" "$kind" "$arg"
  done 3< "$PLUGINFILE"
  exit 0
fi

# Pass 1: register marketplaces (non-fatal — "already added" is fine).
while read -r kind arg _ <&3 || [ -n "$kind" ]; do
  case "$kind" in ''|\#*) continue ;; esac
  [ "$kind" = "marketplace" ] || continue
  echo "==> marketplace add: $arg"
  run claude plugin marketplace add "$arg" || echo "   (already added or unreachable: $arg)"
done 3< "$PLUGINFILE"

# Pass 2: install plugins (non-fatal — one bad plugin shouldn't stop the rest).
while read -r kind arg _ <&3 || [ -n "$kind" ]; do
  case "$kind" in ''|\#*) continue ;; esac
  [ "$kind" = "plugin" ] || continue
  echo "==> plugin install: $arg"
  run claude plugin install "$arg" -s user || echo "   (failed: $arg)"
done 3< "$PLUGINFILE"

echo "==> Done."
