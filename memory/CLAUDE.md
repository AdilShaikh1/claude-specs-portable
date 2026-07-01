# Global working rules

These are my durable, cross-project preferences. They apply on every machine and in
every repo unless a project's own CLAUDE.md overrides them.

## Git & version control
- Read-only git is fine without asking: diff, show, status, log, blame, and
  assembling read-only artifacts from them — a diff/review package, a change ledger.
- Anything that writes or changes state I NEVER run — you run those yourself: add,
  commit, push, checkout, reset, rebase, merge, tag, branch edits.
- `gh`/`git` are read-only toward the outside world: never post PR comments, review
  replies, approvals, merges, or pushes as you.
- Never reference the assistant in commits or PRs (no Co-Authored-By, no generation
  footer, no AI mention).
- Commit messages (when you ask me to draft one): lead with the repo's ticket tag
  (e.g. ABC-123:); no backticks or $(); short subject, body only for the non-obvious
  why.

## Workflow & process
- Plan first: write the proposed edits to the plan file before the first edit, so the
  scope can be reviewed.
- Always ask, never assume — confirm design details, formulas, and root causes before
  coding or concluding. Treat every analysis output as a hypothesis, not a verdict:
  verify it against the real data/code before writing it down, and when you can't
  verify, say "not verified" rather than fill the gap with a plausible story. Don't
  declare victory or defeat (no "this works" / "dead end" / "root cause is X") from a
  single run; one contradicting data point → stop and re-verify, don't defend.
- Lead with the simplest alternative; don't over-engineer. Preference order:
  existing config > published/available data > off-the-shelf tool > small reuse >
  new code.
- Put scratch/tmp output under a gitignored project scratch dir, never `/tmp`.
- For subagent-driven development or ANY multi-subagent workflow, always run two
  dedicated review roles: (1) a logic/correctness overseer and (2) a code-quality
  reviewer. The overseer is the cross-cutting catch-net for final sign-off. For
  robotics / 3D-perception work, give the overseer the "Head of Robotics & 3D
  Perception" persona — math, coordinate frames, observability, numerical
  correctness.

## Verification discipline
- Don't call work "done" on unit tests + a clean build alone — run the real
  end-to-end and inspect the actual output.
- Verify each change incrementally (edit → unit test → run); don't batch many edits
  and defer verification to the end.
- Measure and test in the production configuration, not a pinned or isolated override
  — isolated numbers don't reflect production and can't be extrapolated from.
- For any analysis, generate a fresh run and analyse that; don't point tools at older
  dumps or stale artifacts.
- When reading diagnostic or visual output, ground the interpretation in the actual
  subject; don't treat your own output as ground truth.
- Sequence: code → tests → build → docs. Update docs only after the build is green.

## Data & debugging
- Debug with real values, never synthetic — synthetic inputs hide real-world effects.
- Never destructively rewrite or overwrite a data or metadata file (reindex, in-place
  convert, etc.) without explicit permission, even on a copy.

## Python
- Prefer the `uv` toolchain: `uv venv` / `uv sync` / `uv add` / `uv run` with a local
  `.venv`. Don't wrap `uv` calls in env-stripping dances.
- Source the project's virtualenv before building or running.
- Match the `.venv` Python version to the runtime's native/C-extension Python (e.g. a
  system module built as a 3.12 C extension needs a 3.12 venv, or it fails at import).

## Documentation conventions
- Brainstorm / discovery docs go to `docs/brainstorms/YYYY-MM-DD-slug.md`; add an
  **Outcome** section when the work lands.
- Author docs under "Adil Shaikh" — never a placeholder like "the Development Team".
