#!/usr/bin/env bash
# optional.sh — interactively install "day-two" optional apps.
#
# Usage:
#   ./optional.sh            # show a menu, pick which apps to install
#   ./optional.sh --all      # install everything, no prompt
#   ./optional.sh --list     # just print the catalog and exit
#   DRY_RUN=1 ./optional.sh   # print the commands instead of running them
#
# To add an app: append a line to APPS below. No install commands to look up.
set -euo pipefail

# Each entry is: type|id|label
#   type=cask -> brew install --cask <id>
#   type=mas  -> mas install <id>   (Mac App Store; needs sign-in + prior "get")
APPS=(
  "cask|balenaetcher|balenaEtcher — SD/USB image writer"
  "cask|winbox|WinBox — MikroTik router config"
  "cask|propresenter|ProPresenter — presentation/worship"
  "cask|omnigraffle|OmniGraffle — diagramming"
  "cask|serial|Serial — serial terminal"
  "cask|realvnc-connect|RealVNC Connect — remote desktop"
  "mas|497799835|Xcode — Apple IDE (large; needs App Store sign-in)"
)

run() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "    [dry-run] $*"
  else
    "$@"
  fi
}

list_apps() {
  local i=1 entry
  for entry in "${APPS[@]}"; do
    printf "  %2d) %s\n" "$i" "${entry##*|}"
    i=$((i + 1))
  done
}

install_one() {
  local entry="$1" type id label
  type="${entry%%|*}"
  id="${entry#*|}"; id="${id%%|*}"
  label="${entry##*|}"
  case "$type" in
    cask)
      echo "==> cask: $id"
      run brew install --cask "$id"
      ;;
    mas)
      echo "==> App Store: $label (id $id)"
      command -v mas >/dev/null 2>&1 || run brew install mas
      run mas install "$id"
      ;;
  esac
}

command -v brew >/dev/null 2>&1 || {
  echo "Homebrew not found — run bootstrap.sh first." >&2
  exit 1
}

case "${1:-}" in
  --list)
    list_apps
    exit 0
    ;;
esac

selected=()
if [ "${1:-}" = "--all" ]; then
  selected=("${APPS[@]}")
else
  echo "Optional / day-two apps:"
  echo
  list_apps
  echo
  printf "Select numbers (space-separated), 'a' for all, 'q' to quit: "
  read -r reply
  case "$reply" in
    a|A) selected=("${APPS[@]}") ;;
    q|Q|"") echo "Nothing selected."; exit 0 ;;
    *)
      for n in $reply; do
        case "$n" in
          ''|*[!0-9]*) echo "Skipping invalid: '$n'" >&2; continue ;;
        esac
        if [ "$n" -ge 1 ] && [ "$n" -le "${#APPS[@]}" ]; then
          selected+=("${APPS[$((n - 1))]}")
        else
          echo "Out of range: $n" >&2
        fi
      done
      ;;
  esac
fi

if [ "${#selected[@]}" -eq 0 ]; then
  echo "Nothing selected."
  exit 0
fi

for entry in "${selected[@]}"; do
  install_one "$entry"
done

echo "==> Done."
