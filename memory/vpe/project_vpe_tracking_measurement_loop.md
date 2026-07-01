---
name: project_vpe_tracking_measurement_loop
description: "Verified per-frame VPE tracking measurement→update→map loop and why the bulge is the predict, not VGICP"
metadata: 
  node_type: memory
  type: project
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

VERIFIED (read end-to-end) per-frame TRACKING loop — `TrackState._observe_tracking`
(`src/vpe_tracking/vpe_tracking/track_state.py`):

1. **predict(dt)** — 6-D CV ESKF [~794].
2. prior pose → `T_world_body_prior` [799-801].
3. **register**(source=`cloud_world`, target=`self.golden_map.points` [the voxel MEANS, not the Gaussian
   voxelmap], `init_T_target_source = inv(T_world_body_prior)`) → `res` [803-816].
   **VGICP's init guess IS the predicted prior pose** — a lagging predict feeds a lagging init.
4. `res` (VGICPResult): `T_target_source` (world→body), `H` (6×6 Gauss-Newton information ≈ Hessian),
   `num_inliers`, `mean_residual`, `valid` (= converged ∧ inliers≥min ∧ residual≤max).
5. observability DIAGNOSTIC: `last_htrans_eig`/`last_hmin_evec` from `marginal_translation_information(res.H)`
   [826] — smallest eigenvalue = blind translation axis (Y on a flat flank).
6. if `res.valid`: `pos_meas,yaw_meas = inv(res.T_target_source)`; motion-consistency GATE; then
   **`R_pos = _hessian_R_pos(res)`** (Censi `R=σ²·H⁻¹`, observability-aware, **USED**) → `update_from_pose(pos_meas, yaw_meas, R_pos)` [847-861].
7. `pos_post,yaw_post = eskf.pose()` [866].
8. **`golden_map.update(cloud_world, pose_to_matrix(pos_post, yaw_post))`** — fuse at the POSTERIOR [908-909],
   gated by `not predict_only ∧ residual≤max ∧ F2-aniso ∧ origin_y≤active_y_max`.

**KEY mechanism (why the bulge is the PREDICT):** because `R_pos` is already Hessian-derived, in the blind Y
direction `R_pos_y` is large → VGICP **already defers to the CV predict in Y** by design. So the along-track
estimate IS the predict; the bulge = the CV predict lagging during accel (no accel state), not VGICP fighting
it. ⇒ the principled bulge lever is the predict (CA/CTRA, doc C2) or IESKF/B2 — NOT loosening VGICP's R.
NB `_hessian_R_yaw` (yaw) was implemented + REVERTED [854-859]; `_hessian_R_pos` (position) is live.
The incremental `golden_map.update` already VGICP-aligns each scan (the register in step 3), so the map SHAPE
is crisp; only its ANCHOR drifts (the bulge) — append already gives crispness, no rebuild needed for that.
See [[project_vpe_obb_le_characterization]].
