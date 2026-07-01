---
name: feedback_snapshots_before_every_inference
description: "Before ANY inference about a tracking/perception run, go through the actual per-frame snapshots — never infer from summary plots/aggregate numbers alone"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

Every time you make an inference about a run (e.g. "X is a lateral drift", "Y is jitter",
"rolling_window is the lever", "the map is contaminated"), you MUST first go through the actual
per-frame snapshots (top/side/front + golden_map views across the whole traverse) — not just
`summary.png` and the scan→CAD/aggregate numbers.

**Why:** The user repeatedly catches inferences drawn from aggregate plots that the snapshots
contradict or refine. Aggregate metrics hide WHERE/WHY the tracking fails; the snapshots show the
actual car vs the OBB/pose/map per frame.

**How to apply:** Before proposing a diagnosis or a tuning direction, read a dense representative
spread of the latest run's snapshots (entry → mid → exit, each view), recognise the actual vehicle in
each ([[feedback_recognize_car_in_snapshots]]), and compare the pose/OBB/map to it concretely. Only
then state an inference. Extends [[feedback_perception_e2e_verification]] ("look at the images not just
numbers ALWAYS") to EVERY inference, not just completion claims.
