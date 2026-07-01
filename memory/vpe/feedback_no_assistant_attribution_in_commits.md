---
name: never-mention-assistant-in-commits-or-prs
description: "Never reference the assistant (Claude/calude/AI/Anthropic) in commit messages, PR descriptions, or any user-facing artifact. Assistant config files (CLAUDE.md, .claude/, .claude.local.md, .claude.json) are gitignored — never include them in diffs or reference them in commit bodies."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 00f6427c-cf0d-4228-a6b6-a27385084601
---

User reserves all user-facing GitHub artifacts (commits, PR
descriptions, review replies) for their own voice. Assistant
attribution is out — no `Co-Authored-By`, no "🤖 Generated with…"
footer, no mention of Claude/calude/AI/Anthropic anywhere in the
prose.

**Why:** reinforced 2026-05-12 ("do not mention claude or calude
related any where", "keep out", "no I mean dont mention it in the
comment anywhere") and again 2026-05-13 ("dont mention claude stuff
and NEVER add calude to the messages. all claude files are to be
gitignored"). The repo's `.gitignore` already excludes `CLAUDE.md`,
`.claude/`, `.claude.local.md`, `.claude.json` as per-user-not-shared
files. Pairs with [[feedback_gh_read_only_never_comment_as_user]] —
the user posts on GitHub themselves; my drafts are text for them to
paste, not commands for me to run.

**How to apply:**
- **Drafting commit messages:** describe the technical change only.
  Never reference `CLAUDE.md` (it's not in the diff anyway) and never
  attach a `Co-Authored-By:` trailer or generation footer, even if a
  default template suggests one.
- **Drafting PR descriptions:** same — technical content only, in
  the user's voice.
- **Inline review replies / commit-message hints in docs:** same.
- **If the user explicitly asks** to include attribution (rare),
  follow that ask. Otherwise default to no mention.
- The `.gitignore` already covers the assistant config files, so a
  proposed diff that touches `CLAUDE.md` is implicitly outside any
  commit scope — don't mention those files in the commit body.
