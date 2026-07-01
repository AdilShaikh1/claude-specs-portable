---
name: feedback_run_e2e_after_every_change
description: "Run the e2e investigation harness after EVERY pipeline change, not just once at the end of a batch"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

On the `v5_vehicle_pose_estimator` pipeline, run the **end-to-end** test after **every** change that touches the live pipeline — not batched up and run once at the end. The user's words: "run e2e test after every change not last."

**Why:** each change is validated in the real pipeline immediately, so a regression is caught at the change that caused it (not discovered at the end of a multi-change batch where it's expensive to bisect). Unit tests passing is necessary but not sufficient — the e2e is the real signal (relates to [[feedback_perception_e2e_verification]]).

**How to apply:** for any tracking/perception live-pipeline edit, the cycle is: edit → unit tests → `source .venv` + ROS + `colcon build --packages-select <pkg>` + source install ([[feedback_source_venv_before_build]]) → `tools/run_investigation.sh booth_test_slow_bag` → inspect the new run's `metrics.csv` + accuracy plots (+ a `--record` MCAP in Foxglove for visual; in-loop PNG snapshots were removed) → only then move to the next change. Offline-tool-only changes (e.g. `eval_scan_vs_cad.py`, plotting) are validated by running the tool itself on the latest run's dumps. Don't queue several pipeline edits and defer the e2e to the end.
