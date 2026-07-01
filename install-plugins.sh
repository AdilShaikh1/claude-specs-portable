#!/usr/bin/env bash
# Install the plugins enabled in settings.json via the Claude Code CLI.
#
# IMPORTANT: `enabledPlugins` in settings.json only ENABLES plugins that are already
# installed locally — it does NOT download/install them. This script does the actual
# install. Run it once on a new machine AFTER `claude` + `/login`, then reload your
# editor/window so they load.
#
# Usage:  ./install-plugins.sh [--dry-run]
#   --dry-run   print the commands it would run; call nothing
set -euo pipefail

DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

DST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$DST/settings.json"
[ -f "$SETTINGS" ] || { echo "No settings.json at $SETTINGS — run ./install.sh first." >&2; exit 1; }

if [ "$DRY" = "0" ] && ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found on PATH. Open Claude Code once (or add it to PATH), then re-run." >&2
  exit 1
fi

# Interpreter to read settings.json — match install.sh (python3, else python).
PY="python3"; command -v python3 >/dev/null 2>&1 || PY="python"
command -v "$PY" >/dev/null 2>&1 \
  || { echo "Need python3 or python to read settings.json — install Python, then re-run." >&2; exit 1; }

# Enabled plugin ids ("name@marketplace") whose value is true, from the live settings.
PLUGINS="$("$PY" -c '
import json, sys
d = json.load(open(sys.argv[1]))
print("\n".join(k for k, v in (d.get("enabledPlugins") or {}).items() if v))
' "$SETTINGS")"
[ -n "$PLUGINS" ] || { echo "No enabled plugins in $SETTINGS — nothing to install."; exit 0; }

# marketplace name -> owner/repo  (extend here for non-official marketplaces)
marketplace_repo() {
  case "$1" in
    claude-plugins-official) echo "anthropics/claude-plugins-official" ;;
    *) echo "" ;;
  esac
}

echo "Registering marketplaces..."
printf '%s\n' "$PLUGINS" | sed 's/.*@//' | sort -u | while IFS= read -r mp; do
  [ -n "$mp" ] || continue
  repo="$(marketplace_repo "$mp")"
  if [ -n "$repo" ]; then
    if [ "$DRY" = "1" ]; then echo "  DRY: claude plugin marketplace add $repo"
    else echo "  + marketplace add $repo"; claude plugin marketplace add "$repo" || true; fi
  else
    echo "  NOTE: marketplace '$mp' has no known repo — register it yourself:"
    echo "        claude plugin marketplace add <owner/repo>"
  fi
done

COUNT="$(printf '%s\n' "$PLUGINS" | grep -c .)"
echo "Installing $COUNT plugin(s)..."
printf '%s\n' "$PLUGINS" | while IFS= read -r p; do
  [ -n "$p" ] || continue
  if [ "$DRY" = "1" ]; then echo "  DRY: claude plugin install $p --scope user"; continue; fi
  echo "  installing $p"
  claude plugin install "$p" --scope user \
    || echo "    FAILED: $p  (logged in? run 'claude' then /login, then re-run this script)"
done

if [ "$DRY" = "1" ]; then
  echo "(dry run — nothing changed)"
else
  echo "Done. Reload your editor/window (VS Code: 'Developer: Reload Window') so the plugins load."
fi
