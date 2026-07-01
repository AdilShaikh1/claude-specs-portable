---
name: project_vpe_tracking_singlethread_executor_gotcha
description: "vpe_tracking node is single-threaded; heavy publishers (golden_map) on the executor STARVE the /vehicle_pose publish — pose published late, not wrong"
metadata: 
  node_type: memory
  type: project
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

The `vpe_tracking` node runs a **single-threaded** rclpy executor (`rclpy.spin`). Any heavy work on a timer/callback runs on that one thread and blocks the others.

Concrete instance: the `/golden_map` viz publisher (2 Hz timer in `tracking_node._on_golden_map_timer`) transforms + voxel-downsamples + serializes the **~80 k-point CAD** on the executor thread, which **blocks the `/vehicle_pose` publish**. Measured (deterministic nt=1 A/B, black bag): with golden_map ON the pose is recorded up to **+385 ms late** vs its own cloud (spiky), vs a flat **~65 ms** with it OFF — so in Foxglove playback the pose **visually trails the cloud**. The pose **value is unaffected** (computed correctly, header-stamp-aligned identical; it's just published late).

**Why `tick_latency` misses it:** `tick_latency_ms` measures the measurement callback's *own* duration (unchanged here) — NOT publish scheduling. So a "no latency change" A/B can be wrong.

**DEBUG LESSON (cost me 2 user corrections):** for a visual "pose lags the cloud" report, compare the **published stream's receive-time** vs the cloud (read `/vehicle_pose` + `/segmented_cloud` header-stamp + MCAP recv-time from the recording), NOT the per-frame `metrics.csv` posterior (which is bit-identical and hides it). Don't conclude from `tick_latency` or the per-frame pose. See [[feedback_always_ask_never_assume]].

**Fix:** `/golden_map` publishing is OFF by default (launch override commented in `vpe_pipeline.launch.py`). If re-enabled for VGICP-fit viz, move it OFF the hot path — separate callback group on a `MultiThreadedExecutor`, or async serialize/publish — never on the executor thread that owns the pose.
