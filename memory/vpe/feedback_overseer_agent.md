---
name: overseer-agent-for-multi-subagent-work
description: "Always designate an extra overseer subagent that all implementer/reviewer subagents report to, when running subagent-driven-development or any multi-subagent workflow"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a7cc3703-1961-42be-9936-cc5737169d93
---

When running subagent-driven-development or any workflow that dispatches multiple subagents (implementer + reviewers), ALWAYS run two dedicated review roles on top of the implementer:
1. a **logic overseer** with the persona **"Head of Robotics & 3D Perception"** — signs off on algorithm/logic correctness (math, frame conventions, observability, numerical safety), NOT style or spec-checkboxes; and
2. a **code-quality checker** — style, clarity, maintainability, test hygiene, spec compliance.
The logic overseer is the cross-cutting catch-net: it gets the full picture and gives the final sign-off before a task (and the whole plan) is marked complete. (User, 2026-06-24: "ALWAYS USE a logic overseer (Head of Robotics and 3D perception) + code quality checker when using SDD.")

**Why:** Individual reviewers can each clear their narrow scope while the work as a whole still drifts from user intent. An overseer with the full picture (task spec + implementer output + every reviewer's verdict) catches alignment gaps the per-reviewer passes miss. Adds one extra subagent invocation per task but is cheap insurance against rework.

**How to apply:**

Per-task workflow becomes:
1. Implementer subagent does the work + self-review.
2. Spec-compliance reviewer.
3. (Fix loop if needed.)
4. Code-quality reviewer.
5. (Fix loop if needed.)
6. **Overseer subagent** — gets the original task spec, the final implementer summary, and both reviewer verdicts. Confirms the work matches user intent end-to-end, not just per-reviewer narrowly. If it flags issues, send back to the implementer.
7. Mark task complete.

At the end of a multi-task plan, also dispatch a final **plan-wide overseer** that gets a summary of every task's outcome + the original plan + every per-task overseer verdict. Final sign-off before declaring the whole plan done.

Applies to: `superpowers:subagent-driven-development`, any custom multi-subagent orchestration. Don't bypass for "small" tasks — the overseer is the catch-net.
