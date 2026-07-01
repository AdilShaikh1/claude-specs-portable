# Portable Claude Code config

A self-contained copy of my Claude Code settings/preferences that installs cleanly on
**native Windows, WSL2+Windows, and native Ubuntu**. No git, no cloud — carry the
folder (or the archive) to the new machine and run the installer.

## What's inside

| Path | What it is |
|------|------------|
| `settings.json` | Plugins, `effortLevel: xhigh`, permission allowlist, Stop/Notification hooks. Hook command + interpreter are **templated** (`__PY__`, `__HOOKS_DIR__`) and filled in at install time. |
| `hooks/claude-notify-hook.py` | OS-detecting notifier (WSL→Windows toast, native Windows, macOS, Linux). Always exits 0. |
| `hooks/claude-notify.ps1`, `set-audio-output.ps1` | Windows PowerShell helpers used by the hook. |
| `skills/grill-me/` | Custom skill. |
| `plugins/blocklist.json` | Blocked-plugins list. |
| `memory/CLAUDE.md` | **Transferable** global rules → installs to `~/.claude/CLAUDE.md` (loads on every machine + project). |
| `memory/vpe/` | Full verbatim snapshot of the project memory (VPE-specific). Installed **only** with `--with-vpe`. |

## NOT included (and why)

- `~/.claude/.credentials.json`, `~/.claude.json` — OAuth tokens, account UUID,
  machineID. Tied to the account/machine; **re-login** after install.
- MCP connector auth — **re-authorize** with `/mcp`.
- `plugins/cache/` — the 12 official plugins re-download from the always-available
  `@claude-plugins-official` marketplace on first run.
- Sessions, transcripts, file-history, ide locks, shell snapshots, caches — machine
  state, not preferences.

## Install

### 0. Get the bundle onto the new machine
Copy `claude-config-bundle.tar.gz` (Linux/WSL/macOS) or `claude-config-bundle.zip`
(Windows) — or the whole `claude-specs-portable/` folder — over via USB / scp / cloud drive,
then unpack (skip this if you copied the folder directly):

```bash
# Linux / WSL / macOS
tar xzf claude-config-bundle.tar.gz && cd claude-specs-portable
```
```powershell
# Windows (PowerShell)
Expand-Archive claude-config-bundle.zip -DestinationPath . ; cd claude-specs-portable
```

### 1. Run the installer

**Linux / WSL / macOS:**
```bash
./install.sh                          # global rules + settings + hooks + skills
./install.sh --with-vpe               # also restore the VPE project memory
./install.sh --with-vpe --set-audio   # ...and set the Windows playback device
```

**Native Windows (PowerShell):**
```powershell
./install.ps1                         # add -WithVpe and/or -SetAudio as needed
```

`--set-audio` / `-SetAudio` runs `set-audio-output.ps1`, which sets the default
Windows playback device (Jabra→Realtek). It's opt-in because it installs a PowerShell
module and changes a system-wide setting.

The installer backs up any existing `settings.json` to `settings.json.bak-N` before
writing, and never touches credentials.

> **Isolated test install:** point `CLAUDE_CONFIG_DIR` at a throwaway dir first —
> `CLAUDE_CONFIG_DIR=./.testinstall ./install.sh` — to verify the bundle without
> touching your real `~/.claude`. That dir is gitignored.

### 2. After install
1. `claude`  →  `/login`  (account is per-machine)
2. `/mcp`  → re-auth connectors (Google Calendar/Drive, Miro, etc.)
3. Plugins re-download on first run.
4. Trigger a Stop event to confirm the notification fires.

## Custom config dir

If you use `CLAUDE_CONFIG_DIR`, the installer honours it (installs there instead of
`~/.claude`). Set it before running `install.sh`/`install.ps1`.

## Regenerating the bundle (on a source machine)

```bash
./export.sh --refresh    # re-pull skills/blocklist/.ps1/VPE-memory from live, then repackage
./export.sh              # just repackage  ->  claude-config-bundle.tar.gz
```
```powershell
./export.ps1 -Refresh    # -> claude-config-bundle.zip
```

`export` deliberately does **not** regenerate the three hand-authored files —
`settings.json`, `hooks/claude-notify-hook.py`, and `memory/CLAUDE.md` — because they
required judgment (templating, OS detection, generalizing project rules into portable
ones). Edit those by hand when they need to change.

## Memory: how the rules are split

- **`memory/CLAUDE.md` (global, always on):** git read-only-allowed stance, plan-first,
  ask-don't-assume, simplest-first, uv, verification discipline (run the real e2e,
  verify incrementally, production config, fresh runs), data/debug rules, doc
  conventions, and the multi-subagent overseer rule.
- **`memory/vpe/` (project-scoped, opt-in):** the VPE `# Project`/`# Reference` facts
  (sensor naming, tracking anchors, accuracy targets, research refs) — only meaningful
  inside the `v5_vehicle_pose_estimator` workspace.

## Gotchas

- **Memory key (`--with-vpe` only):** project memory installs under
  `projects/<sanitized-home-path>/memory/`. The installer derives that key
  (`/home/bob`→`-home-bob`, `C:\Users\bob`→`C--Users-bob`) and prints it — if Claude
  doesn't pick it up, move the folder to match the dir you run `claude` from.
- **Notifications need their backend:** native Linux uses `notify-send` +
  `canberra-gtk-play`/`paplay` (falls back to a terminal bell); macOS uses
  `osascript`/`afplay`; WSL/Windows use PowerShell. Missing tools just mean a silent
  no-op, never an error.
