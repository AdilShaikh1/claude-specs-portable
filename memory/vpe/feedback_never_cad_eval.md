---
name: feedback_never_cad_eval
description: Never run the tracking investigation harness with --cad-eval
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

NEVER pass `--cad-eval` to `tools/run_investigation.sh`. Run the black-bag/Tiguan tracking e2e as `tools/run_investigation.sh <bag> --record` (record for Foxglove/offline pose analysis), WITHOUT `--cad-eval`.

**Why:** user directive (2026-06-29), explicit. The `--cad-eval` scan→CAD comparison gates (e.g. the `le_align_err_m` approach gate) are not the metric to chase and its verdict shouldn't drive decisions — analogous to [[feedback_always_production_config_e2e]] (don't judge by a non-production eval mode).

**How to apply:** judge a tracking change by the core run metrics (predict_only fraction, VGICP success rate, containment_ratio, body_xmax origin-drift) and by inspecting the `--record` MCAP / `vehicle_pose_echo.log` for pose+yaw smoothness and lateral drift — not by `--cad-eval` le_align gates. See [[feedback_always_fresh_e2e]] (fresh run each time) and [[feedback_perception_e2e_verification]].
