---
name: feedback_always_production_config_e2e
description: "always run the tracking e2e in production config (full adaptive filter), never CV-pinned isolation as the headline result"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

When running the VPE tracking e2e for the user to read accuracy from, ALWAYS use the production configuration: the full adaptive constant-acceleration filter (`q_accel=1.0`, `q_vel_max_scale=50`, `initial_accel_var=1.0`) and the real gate, with NO harness env overrides. NEVER present a CV-pinned isolation run (`Q_ACCEL=0 Q_VEL_MAX_SCALE=1 INITIAL_ACCEL_VAR=0`) as the result the user reads.

**Why:** CV-pin freezes the filter into a constant-velocity stub to make the map the only variable — useful only for internal attribution. Those numbers do not reflect deployed behaviour, so the user cannot infer anything actionable from them. User, emphatically: "ALWAYS RUN PRODUCTION RUNS, STOP SLACKING OFF."

**How to apply:** default every tracking e2e to the production `tracking.yaml` (no env overrides). If an isolation run is genuinely needed to attribute one change, run it as an explicitly-labelled side-diagnostic, never the headline. Relates to [[feedback_debug_with_real_bag]] and [[feedback_run_e2e_after_every_change]].
