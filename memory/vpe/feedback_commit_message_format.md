---
name: commit-message-format
description: "When drafting commit messages, prefix the subject with the repo's Jira ticket tag (e.g. V5-136:); never use backticks or shell metacharacters; keep messages concise"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f1e37d28-a636-483f-b82e-0e1ffa868c50
---

When I draft a commit message for the user to paste into a shell:

1. **Lead with the Jira ticket tag.** Each repo enforces a tag prefix
   for Jira integration. Check recent commits on the current branch
   (or the branch name itself — e.g. feature/V5-136-… → V5-136) and
   match the existing style. For v5_vehicle_pose_estimator the format
   is: V5-136: <subject> (uppercase ticket, colon, single space,
   then imperative subject).
2. **No backticks** anywhere — not around code, function names, file
   names, commands, anything. The user pastes into bash where backticks
   trigger command substitution: backtick-tini-backtick becomes a
   call to $(tini) which tries to execute tini and substitutes the
   output, breaking the commit.
3. **No $(...) or $var** for the same reason.
4. **Keep it concise** — short subject line, body only when the why
   is genuinely non-obvious. Don't pad with restating what.
5. **No internal double quotes** in the message body. They close the
   outer string in `git commit -m "..."`. Use single quotes ('like this'),
   hyphenated identifiers (foo-bar-baz instead of "foo bar baz"), or
   reword to avoid quoting entirely.
6. **For multi-line bodies, recommend HEREDOC over `-m "..."`.** Single-
   quoted HEREDOC delimiter disables all shell expansion, so backticks,
   quotes, and $vars are inert:
   ```
   git commit -F - <<'EOF'
   TICKET: subject

   Body with "quotes" and `backticks` and $vars is safe inside a
   single-quoted HEREDOC.
   EOF
   ```
   Use this whenever the body has more than one line or contains any
   character that would be shell-special inside double quotes.

**Why:** Three real incidents in one session:
- Backticks around 'command:', 'tini', 'vpe-stub' triggered command-
  not-found errors when user pasted into shell; heredoc broke mid-
  paste, commit was lost.
- Message with no Jira tag — user's workflow requires it because Jira
  links commits to tickets by that prefix.
- Inner double quotes around 'restore healthz probe ports' closed the
  outer `-m "..."` string; bash parsed the remaining words (restore,
  healthz, probe, ports) as pathspecs → `error: pathspec 'healthz'
  did not match any file(s) known to git`.

**How to apply:**
- Before drafting: figure out the ticket tag. The branch name is the
  most reliable source (feature/<TICKET>-... or fix/<TICKET>-...). If
  unclear, ask the user once or run gh api repos/<owner>/<repo>/commits
  to see the last few subjects.
- Subject: TICKET: <imperative phrase>, ≤ ~70 chars including the tag.
- Quote code-ish tokens with single quotes ('like this') or bare,
  no backticks. e.g. write: 'tini' or just tini — never backtick-tini.
- For phrases that would normally take double quotes ("restore X"), use
  single quotes ('restore X'), hyphens (restore-X), or italics-style
  emphasis via context. Never inner double quotes.
- For file paths, write them bare: src/vpe_nats/vpe_nats/bridge_node.py
- For function names, bare or single-quoted: stop_healthz.
- Body: 3-6 lines max unless user asks for more.
- If body has > 1 line OR any potentially shell-special char, give the
  user the HEREDOC form instead of `-m "..."`.

This applies to commit message drafts I hand to the user. PR
descriptions go through gh/textareas where backticks and quotes are
fine, but since I don't know how the user will paste a commit message,
default to shell-safe (no backticks, no inner double quotes, HEREDOC
for multi-line) for safety.
