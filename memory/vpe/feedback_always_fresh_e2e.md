---
name: feedback_always_fresh_e2e
description: Always run a fresh production e2e for analysis; never reuse existing dumps
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

For ANY tracking accuracy / truth / drift analysis, run a NEW e2e and analyse THAT run's output — never point a tool at an older `INTERNAL/diagnostics_runs/tracking/<ts>/` dir or recycle existing `dumps/`. User: "run new e2e ALWAYS, do not use existing dumps."

**Why:** stale dumps may be from a different config or pre-edit code, so conclusions drawn from them are untrustworthy and waste the user's review.

**How to apply:** build first, then `bash tools/run_investigation.sh <bag> --cad-eval` (add `--record` for a Foxglove MCAP; in-loop PNG snapshots were removed), production config (no env overrides), then run the eval/`eval_trajectory_vs_cad.py` against the fresh run dir. Pairs with [[feedback_always_production_config_e2e]], [[feedback_run_e2e_after_every_change]], and [[feedback_perception_e2e_verification]].
