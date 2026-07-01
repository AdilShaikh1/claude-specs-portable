---
name: test-before-docs
description: "Always run tests/verification before updating README and docs, never the other way around"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a7cc3703-1961-42be-9936-cc5737169d93
---

Run tests and verification (unit tests, colcon build, end-to-end smoke) BEFORE updating README files and documentation. Never update docs that claim a change works until the tests/build have actually passed. Docs are **the brain of the project** — always update them at the very end once tests pass, never skip them (user, 2026-06-24).

**Why:** During the vpe_preprocessing + vpe_segmentation → vpe_perception merge (2026-05-18), I updated CLAUDE.md, DEVELOPER_GUIDE.md, the package readme, and bannered the handover docs before running unit tests or colcon build. The user objected: "ALWAYS UPDATE README AND DOCS AFTER TESTS NOT BEFORE." The principle is to avoid documenting behaviour that turns out broken on first run.

**How to apply:**
- During multi-step refactors/migrations, sequence: code → unit tests → colcon/build → docs.
- If a doc edit is interleaved with code (e.g. an in-code docstring), that's fine.
- Doc updates that describe state ("the package is now called X") wait until the build is green.
- Applies to commit-time too: don't draft a commit message with "fixes Y" until you've verified Y is actually fixed.
