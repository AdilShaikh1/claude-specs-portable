---
name: gh-and-git-are-read-only-never-post-comment-as-the-user
description: "Treat both git and gh as read-only by default. Never run any command that writes on the user's behalf — PR comments, issue comments, review replies, reviews, releases, pushes, merges, label changes — even when read-only access has been granted."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 00f6427c-cf0d-4228-a6b6-a27385084601
---

The user reserves all *authored* actions on GitHub (and git) for
themselves. Read-only commands are fine when granted; anything that
posts content under their identity is not.

**Why:** stated 2026-05-12 after I posted replies on PR #6 inline
review threads via `gh api -X POST .../pulls/comments/{id}/replies`.
Those replies went up as `adilshaikhDG` (the user's GitHub account),
which they explicitly do not want me doing. The principle is the same
as [[feedback_never_commit_push]] — anything that gets attributed to
them, they author themselves.

**How to apply:**
- `gh` commands: only the read forms (`gh pr view`, `gh pr list`,
  `gh pr diff`, `gh api ...` with no `-X POST/PUT/PATCH/DELETE`,
  `gh issue view`, `gh release list`, etc.).
- Do NOT invoke: `gh pr comment`, `gh pr review`, `gh pr merge`,
  `gh pr close`, `gh pr edit`, `gh issue comment`, `gh issue close`,
  `gh release create`, or any `gh api -X POST/PUT/PATCH/DELETE`
  including thread replies (`/pulls/comments/{id}/replies`).
- When the user wants to respond to a PR review comment, draft the
  reply *as text* — they post it themselves. Same pattern as drafting
  commit messages.
- git: read-only forms only (`git status`, `git diff`, `git log`,
  `git show`, `git branch -v`, `git rev-parse`). No `commit`, `push`,
  `merge`, `rebase`, `tag`, `add`, `restore`, `checkout` — even when
  the user has granted "read-only git OK" for a turn.
- If unsure whether a command writes, assume it does and ask first.
