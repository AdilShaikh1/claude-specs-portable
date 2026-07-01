#!/usr/bin/env bash
# (Re)package this bundle into claude-config-bundle.tar.gz.
# Usage:  ./export.sh [--refresh]
#   --refresh   first re-pull the verbatim parts (skills, blocklist, .ps1 helpers,
#               VPE memory, keybindings) from this machine's live ~/.claude.
#
# The three hand-authored files are intentionally NOT regenerated:
#   settings.json (templated), hooks/claude-notify-hook.py (OS-detecting), memory/CLAUDE.md
set -euo pipefail

BUNDLE="$(cd "$(dirname "$0")" && pwd)"
SRCCFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

if [ "${1:-}" = "--refresh" ]; then
  echo "Refreshing verbatim parts from $SRCCFG ..."
  rm -rf "$BUNDLE/skills"; mkdir -p "$BUNDLE/skills"
  [ -d "$SRCCFG/skills" ] && cp -r "$SRCCFG/skills/." "$BUNDLE/skills/" || true
  [ -f "$SRCCFG/plugins/blocklist.json" ] && cp "$SRCCFG/plugins/blocklist.json" "$BUNDLE/plugins/blocklist.json" || true
  for f in claude-notify.ps1 set-audio-output.ps1; do
    [ -f "$SRCCFG/hooks/$f" ] && cp "$SRCCFG/hooks/$f" "$BUNDLE/hooks/$f" || true
  done
  KEY="$(printf '%s' "$HOME" | sed 's#/#-#g')"
  MEMDIR="$SRCCFG/projects/$KEY/memory"
  if [ -d "$MEMDIR" ]; then
    rm -f "$BUNDLE"/memory/vpe/*.md
    cp "$MEMDIR"/*.md "$BUNDLE/memory/vpe/"
    echo "Refreshed VPE memory snapshot from $MEMDIR"
  fi
  [ -f "$SRCCFG/keybindings.json" ] && cp "$SRCCFG/keybindings.json" "$BUNDLE/keybindings.json" || true
  echo "NOTE: settings.json, hooks/claude-notify-hook.py, memory/CLAUDE.md are hand-maintained (left as-is)."
fi

OUT="$BUNDLE/claude-config-bundle.tar.gz"
# Build to a temp file OUTSIDE the archived tree so tar never sees its own output
# change mid-read, then move it into place.
TMP="$(dirname "$BUNDLE")/.cpb-build.$$.tar.gz"
rm -f "$OUT" "$TMP"
tar czf "$TMP" -C "$(dirname "$BUNDLE")" \
  --exclude='*.tar.gz' --exclude='*.zip' --exclude='*.bak-*' \
  --exclude='.testinstall' --exclude='.verify' \
  "$(basename "$BUNDLE")"
mv "$TMP" "$OUT"
echo "Wrote $OUT ($(du -h "$OUT" | cut -f1))"
