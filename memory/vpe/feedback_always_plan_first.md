---
name: always-plan-first-write-to-plan-file-before-editing
description: "Before making any code edits (even for small or 'clear' fixes), write the proposed changes to the plan file first. The user reviews the plan there before approving execution. Skipping this step and going straight to edits is grounds for rejection — even when not in formal plan mode."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 00f6427c-cf0d-4228-a6b6-a27385084601
---

The user has reinforced this rule multiple times — "ALWAYS PLAN FIRST",
"where is the plan?" — when I've started editing files for fixes that
seemed self-evidently correct (e.g. a multi-item Copilot review where
each item was mechanical).

**Why:** stated repeatedly through 2026-05-13 / 2026-05-14. The plan
file is the user's review surface. Without it they can't see the full
scope of intended changes, can't catch scope creep, and can't verify
that my interpretation of feedback matches theirs. "I'll plan as I go"
is not acceptable — the plan must exist *as a written document* before
the first edit.

**How to apply:**
- For any task touching multiple files or doing more than a single
  one-line obvious fix: write a plan into the existing plan file at
  `/home/adil/.claude/plans/<current-plan>.md` BEFORE the first
  `Edit` / `Write` call.
- The plan should include: context, the specific edits with `diff`
  blocks, verification steps, and any decisions / out-of-scope notes.
- Even when *not* in formal plan mode (no `<system-reminder>` saying
  "Plan mode is active"), this still applies. The rule is independent
  of the harness's plan-mode flag.
- Trivially small edits (single-character typo fix, single-line value
  change explicitly requested by name) may proceed without a plan,
  but when in doubt, plan.
- Pair with `[[feedback_never_commit_push]]` and
  `[[feedback_gh_read_only_never_comment_as_user]]`: those govern
  what to commit/post, this governs what to edit in the first place.
