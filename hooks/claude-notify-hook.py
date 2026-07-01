#!/usr/bin/env python3
"""Claude Code Stop / Notification hook (cross-platform).

Shows a desktop notification (+ sound) describing WHICH project, WHICH session
and WHAT task, so a notification is meaningful when several sessions are open.

Usage (from settings.json hook):
    python3 claude-notify-hook.py <done|input> [sound-override]

Self-detects the environment and routes the notification:
  - WSL2          -> Windows toast via powershell.exe + sibling claude-notify.ps1
  - native Windows-> claude-notify.ps1 directly (or winsound fallback)
  - macOS         -> osascript display notification + afplay
  - native Linux  -> notify-send + paplay/canberra, else terminal bell

Every code path is wrapped so the hook ALWAYS exits 0 — it must never break a
session, regardless of OS, missing tools, or a malformed payload.
"""
import json
import os
import subprocess
import sys

HOOK_DIR = os.path.dirname(os.path.abspath(__file__))
PS1 = os.path.join(HOOK_DIR, "claude-notify.ps1")

# Default sounds per environment (overridable via argv[2]).
WIN_SOUND = {"done": r"C:\Windows\Media\notify.wav",
             "input": r"C:\Windows\Media\chimes.wav"}
MAC_SOUND = {"done": "/System/Library/Sounds/Glass.aiff",
             "input": "/System/Library/Sounds/Ping.aiff"}


def is_wsl():
    if sys.platform != "linux":
        return False
    try:
        with open("/proc/version", "r", errors="ignore") as f:
            return "microsoft" in f.read().lower()
    except Exception:
        return False


def extract_task(transcript_path):
    """Best 'what task' string: session aiTitle, else last user prompt."""
    if not transcript_path or not os.path.exists(transcript_path):
        return ""
    ai_title = ""
    last_prompt = ""
    try:
        with open(transcript_path, "r", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                t = row.get("type")
                if t == "ai-title" and row.get("aiTitle"):
                    ai_title = row["aiTitle"]
                elif t == "last-prompt" and row.get("lastPrompt"):
                    last_prompt = row["lastPrompt"]
    except Exception:
        pass
    return ai_title or last_prompt


def to_windows_path(linux_path):
    """Convert a WSL path to a Windows path for powershell.exe -File."""
    try:
        out = subprocess.run(["wslpath", "-w", linux_path],
                             capture_output=True, text=True, timeout=5)
        win = out.stdout.strip()
        if win:
            return win
    except Exception:
        pass
    return linux_path


def notify_windows(title, body, sound, ps1_path):
    cmd = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass",
           "-File", ps1_path, "-Title", title, "-Message", body]
    if sound:
        cmd += ["-Sound", sound]
    try:
        subprocess.run(cmd, stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL, timeout=20)
    except Exception:
        try:
            import winsound  # native Windows only
            winsound.MessageBeep()
        except Exception:
            pass


def notify_macos(title, body, status):
    try:
        subprocess.run(
            ["osascript", "-e",
             f'display notification {json.dumps(body)} with title {json.dumps(title)}'],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15)
    except Exception:
        pass
    snd = MAC_SOUND.get(status, MAC_SOUND["done"])
    if os.path.exists(snd):
        try:
            subprocess.run(["afplay", snd], stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL, timeout=15)
        except Exception:
            pass


def notify_linux(title, body, status):
    sent = False
    try:
        subprocess.run(["notify-send", "-a", "Claude Code", title, body],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                       timeout=10)
        sent = True
    except Exception:
        pass
    # Sound: prefer a freedesktop event sound, else fall back to a bell.
    event = "complete" if status != "input" else "message"
    for player in (["canberra-gtk-play", "-i", event],
                   ["paplay", f"/usr/share/sounds/freedesktop/stereo/{event}.oga"]):
        try:
            r = subprocess.run(player, stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL, timeout=10)
            if r.returncode == 0:
                return
        except Exception:
            continue
    if not sent:
        sys.stderr.write("\a")  # terminal bell as last resort


def main():
    status = sys.argv[1] if len(sys.argv) > 1 else "done"
    sound_override = sys.argv[2] if len(sys.argv) > 2 else ""

    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    cwd = payload.get("cwd") or os.getcwd()
    transcript = payload.get("transcript_path") or ""
    session_id = payload.get("session_id") or ""
    message = payload.get("message") or ""

    project = os.path.basename(cwd.rstrip("/\\")) or cwd
    sid = session_id[:8]

    task = extract_task(transcript) or message or "(task)"
    task = " ".join(task.split())
    if len(task) > 90:
        task = task[:89] + "..."

    title = f"{project} - Needs your input" if status == "input" else f"{project} - Done"
    body = task + (f"\n#{sid}" if sid else "")

    if is_wsl():
        notify_windows(title, body, sound_override or WIN_SOUND.get(status, ""),
                       to_windows_path(PS1))
    elif os.name == "nt":
        notify_windows(title, body, sound_override or WIN_SOUND.get(status, ""), PS1)
    elif sys.platform == "darwin":
        notify_macos(title, body, status)
    else:
        notify_linux(title, body, status)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)