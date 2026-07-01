---
name: feedback_always_record_e2e
description: Always pass --record on every tracking/perception e2e investigation run (Foxglove MCAP)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

Always run `tools/run_investigation.sh` with `--record` on EVERY e2e run — including parameter sweeps and quick checks, not just final verification.

**Why:** the user inspects each run's MCAP visually in Foxglove frame-by-frame; a run without `--record` produces no MCAP and has to be re-run.

**How to apply:** append `--record` to every `run_investigation.sh` invocation. Still NEVER `--cad-eval`. See [[feedback_perception_e2e_verification]], [[feedback_run_e2e_after_every_change]], [[feedback_never_cad_eval]].
