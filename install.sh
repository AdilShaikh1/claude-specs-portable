#!/usr/bin/env bash
# Install the portable Claude Code config into this machine's ~/.claude.
# Usage:  ./install.sh [--with-vpe] [--set-audio]
#   --with-vpe    also restore the VPE-specific project memory (memory/vpe/)
#   --set-audio   set the default Windows playback device (WSL/Windows; runs the .ps1)
#
# Secrets are NEVER touched: you log in separately after install (claude /login).
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
WITH_VPE=0; SET_AUDIO=0
for arg in "$@"; do
  case "$arg" in
    --with-vpe)  WITH_VPE=1 ;;
    --set-audio) SET_AUDIO=1 ;;
    *) echo "Unknown option: $arg (use --with-vpe, --set-audio)" >&2; exit 2 ;;
  esac
done

echo "Source bundle : $SRC"
echo "Target config : $DST"
mkdir -p "$DST/hooks" "$DST/skills" "$DST/plugins"

# 1. Hooks, skills, plugin blocklist (verbatim) ------------------------------
cp "$SRC/hooks/"*.py "$SRC/hooks/"*.ps1 "$DST/hooks/" 2>/dev/null || true
chmod +x "$DST/hooks/"*.py 2>/dev/null || true
cp -r "$SRC/skills/." "$DST/skills/"
cp "$SRC/plugins/blocklist.json" "$DST/plugins/blocklist.json"

# 2. settings.json (template -> real paths) ----------------------------------
PY="python3"; command -v python3 >/dev/null 2>&1 || PY="python"
HOOKS_DIR="$DST/hooks"
if [ -f "$DST/settings.json" ]; then
  for n in 1 2 3 4 5 6 7 8 9; do
    [ -e "$DST/settings.json.bak-$n" ] || { cp "$DST/settings.json" "$DST/settings.json.bak-$n"; echo "Backed up existing settings -> settings.json.bak-$n"; break; }
  done
fi
sed -e "s|__PY__|$PY|g" -e "s|__HOOKS_DIR__|$HOOKS_DIR|g" \
    "$SRC/settings.json" > "$DST/settings.json"

# 3. Optional keybindings ----------------------------------------------------
[ -f "$SRC/keybindings.json" ] && cp "$SRC/keybindings.json" "$DST/keybindings.json"

# 4. Global memory: transferable rules -> ~/.claude/CLAUDE.md -----------------
cp "$SRC/memory/CLAUDE.md" "$DST/CLAUDE.md"
echo "Installed global rules -> $DST/CLAUDE.md"

# 5. Optional VPE project memory --------------------------------------------
if [ "$WITH_VPE" = "1" ]; then
  KEY="$(printf '%s' "$HOME" | sed 's#/#-#g')"   # /home/bob -> -home-bob
  MEM="$DST/projects/$KEY/memory"
  mkdir -p "$MEM"
  cp "$SRC/memory/vpe/"*.md "$MEM/"
  echo "Installed VPE project memory -> $MEM"
  echo "  (verify this key matches the dir you run 'claude' from; move it if not)"
fi

# 6. Optional: set the default Windows playback device (Windows-side audio) --
if [ "$SET_AUDIO" = "1" ]; then
  if command -v powershell.exe >/dev/null 2>&1; then
    echo "Setting default Windows playback device..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass \
      -File "$(wslpath -w "$DST/hooks/set-audio-output.ps1")" 2>/dev/null || true
  else
    echo "Skipping --set-audio: powershell.exe not found (Windows-side audio only)."
  fi
fi

cat <<EOF

Done. Next steps on this machine:
  1. Run:  claude
  2. Log in:  /login           (OAuth/account is per-machine, not bundled)
  3. Re-auth MCP connectors:  /mcp
  4. Plugins re-download on first run (official marketplace is always available).
  5. Trigger a Stop event to confirm the notification hook fires.
EOF
