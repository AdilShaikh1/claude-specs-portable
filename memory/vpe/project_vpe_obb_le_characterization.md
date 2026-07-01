---
name: project_vpe_obb_le_characterization
description: "Verified OBB leading-edge signal characterization (variance, le_align, LiDAR-loss geometry) for VPE tracking"
metadata: 
  node_type: memory
  type: project
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

VERIFIED facts about the perception OBB leading-edge as a tracking signal (slow-bag e2e + code):

- **`le = obb_leading_edge(center, yaw, dims)`** = `center[:2] + (length/2)·f`, `base_z = center_z − height/2`
  (`reference.py:103-116`). So **`le_y` rides the OBB LENGTH extent** (and the disambiguated yaw).
- **Per-frame VARIANCE (in-zone, jitter around the smooth trend, 1σ):** OBB `le_y` front-face **63 mm**;
  ESKF `y` 23 mm; **VGICP `meas_y` 14 mm (smoothest)**; `obb_len` alone **105 mm**; lateral `le_err_lat`
  (X) ~22 mm. ⇒ the OBB le is the **HIGH-VARIANCE** signal; VGICP is the smoothest. The OBB's real problem
  is **variance, not an established bias.**
- **`le_align_err_m = (obb_leading_edge − pos_post)·fwd`** (`track_state.py:1006-1007`); in-zone **mean
  +59 mm** (OBB sits ahead of the ESKF origin). **DO NOT attribute this to OBB forward-bias** — most likely
  the DEFINITIONAL offset between the INIT-anchored ESKF origin and the current OBB front-face; the bias is
  UNKNOWN. The `track_state.py:833` "per-frame re-measurement induced a forward bias" comment is about a
  *different* reverted approach and is NOT proof the OBB `le` is biased (corrected 2026-06-21).
- **LiDAR-loss geometry:** 3 LiDARs = JT_SL/JT_SR (sides) + JT_T (top). Losing a **side** degrades the
  **LATERAL X** (one-sided cluster → lateral center/width bias, possible OBB-yaw rotation); the **forward Y
  `le_y` is robust** (the front-most point survives via the top + the other side). So sensor loss is an
  X problem, not a Y problem.
- **`sensor_mask`** (bitmask of contributing LiDARs) + `num_sensors` are computed in
  `n_of_m_synchronizer.py` and carried in `FusedCloud.msg`, but are **NOT in `SegmentedCloud.msg`** → not
  visible to tracking without adding a field.

**Design implication:** for an OBB-`le_y`→ESKF Y measurement, set R = the measured covariance (~63 mm² Y);
since VGICP is blind in Y (`R_pos_y` already large, see [[project_vpe_tracking_measurement_loop]]), the OBB
then becomes the PRIMARY Y constraint — not a "gentle high-R nudge." No bias gate needed (bias unproven);
the variance is handled by R + multi-frame averaging.

- **`le_align` leading-edge lag is REAL (confirmed 2026-06-25, cloud-extraction; user was right).**
  In Foxglove the golden map's front sits BEHIND the live scan's front while the front is visible and the car
  drives forward. PROOF (run `20260625T151043Z`): extracted `/golden_map` vs `/viz/segmented_cloud` at **identical
  stamps** (189/189 exact, Δ=0.0 ms → NOT a viz artifact) and compared the **98th-pctile leading-edge Y** per
  frame. During forward drive (vy>0.3) the **live front is AHEAD of the golden/tracked front EVERY frame,
  one-signed: +82…+164 mm** (CSV `le_align` +30…+101 mm). Even at rest there's a ~+44 mm (`le_align`) / +100 mm
  (98-pctile) baseline offset (init-anchor/front-bulge definitional, see [[project_vpe_init_anchor_leaf_findings]]).
  CAUTION — earlier in the SAME session I wrongly "resolved" this as not-a-lag by sampling the **FOV-EXIT troughs**
  (frames 134–146, `le_align` −0.28 m, where the live front RETRACTS as it leaves the FOV and golden appears
  ahead). Those negative troughs are a DIFFERENT effect; the approach-phase positive offset is the real lag.
  Don't conflate FOV-exit with the visible-approach lag. `body_xmax` is +6 mm constant but that ONLY measures
  golden-vs-origin (internally consistent by construction) — it CANNOT see origin-vs-live-scan lag.
  MECHANISM: VGICP is Y-blind on the long flat flank (`R_pos_y` large → it can't pin the front, requested Δy
  small because UNOBSERVABLE not because aligned) + CV-predict lags in motion + the OBB leading edge is NOT yet
  fed as a Y measurement. FIX = the deferred OBB-`le_y`→ESKF Y-measurement (PLAN 2 T3): the leading edge IS
  observable while visible, so it pins the front. A threshold/reject gate is the WRONG lever (would add coasting).
  Scripts: `INTERNAL/tmp/poselag/{le_lag,cloud_offset}.py` (rosbag2_py + sensor_msgs_py, **system python3 + ROS**,
  NOT the venv — rclpy/rosbag2 aren't in `.venv`).
