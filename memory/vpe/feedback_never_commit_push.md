---
name: Never run git commit or git push — user does it themselves
description: Even when the user grants permission for read-only git commands (status, diff, log), they still want to run commit and push themselves — never invoke either via Bash
type: feedback
originSessionId: 00f6427c-cf0d-4228-a6b6-a27385084601
---
The user reserves `git commit` and `git push` for themselves,
even when they've explicitly authorized read-only git inspection
in the current turn (e.g. "you can use read-only commands to get
the diff").

**Why:** stated 2026-05-11 — "never commit/push yourself I
will". The existing global rule already bars all git commands
without permission; this is the narrower statement that *commit
and push specifically* are never to be delegated, regardless of
how broad the read-only permission feels.

**How to apply:**
- When the user asks for a "commit message", produce the message
  as text only. Do not run `git commit`.
- If they grant permission for `git status` / `git diff` /
  `git log`, do not assume that extends to `commit` or `push`.
- Stage files (`git add`) only if explicitly asked; never
  combine with a commit invocation.
