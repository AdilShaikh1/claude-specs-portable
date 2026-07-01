---
name: project-vpe-tracking-leading-edge-reference
description: "vpe_tracking must anchor on the vehicle's CURRENT-FRAME leading-edge-at-base point (not perception's OBB centre); angle is measured w.r.t. +Y travel axis"
metadata: 
  node_type: memory
  type: project
  originSessionId: 43e0b5b4-4d8a-4576-b4d1-e0cad1dc85c0
---

In `v5_vehicle_pose_estimator/src/vpe_tracking`, the body-frame reference point for the golden map, ESKF, and reported OBB is the **leading edge at the base of the wheels, laterally centred** — NOT perception's OBB centre. (User-directed correction, 2026-05-27, after e2e showed the tracked box leading the car cluster by ~1.7 m.)

**Why the OBB centre was wrong:** perception's OBB centre is observation-dependent — it creeps backward along the body as the car reveals itself entering the booth. So (a) the golden map (anchored at the *oldest* init frame's OBB centre) and the ESKF (initialised at the *newest* frame's OBB centre) used different origins → constant pose bias, velocity ~3× low, and the self-built map smeared to 55k points instead of fusing into a crisp car; (b) drawing the full-size OBB on that point put the box ahead of the car.

**The leading edge is stable** under partial observation: the front bumper and ground plane are at the same geometric extreme from the first frame the car enters.

**Definition (per current frame's cluster):**
- forward (along heading, disambiguated toward +Y travel): ~99th percentile
- lateral (perpendicular to heading): midpoint
- up (world Z): ~1st percentile (ground / base of wheels)
Mirrors the DeGould prototype's `ESKFInitialiser` (`ground_percentile=1`, `leading_percentile=99`).

**Angle convention:** heading is measured **w.r.t. +Y** (straight travel = 0°), not from +X. Perception emits OBB yaw from +X (`yaw = arctan2(heading_y, heading_x)`; a car facing +Y reads `yaw ≈ π/2`), so the Y-referenced heading is `θ_Y = world_yaw − π/2`. Internal transforms/ESKF may stay in world-yaw, but the leading-edge "forward" must be disambiguated toward +Y and the reported heading expressed as deviation from +Y.

**OBB output:** built from the (tracked) leading edge + the **current frame's** length/width/height. The box extends backward (−forward·length), ±lateral (width/2), and up (height) from the leading edge. Reported `obb_center` = derived geometric centre = `leading_edge − forward·(length/2) + up·(height/2)` (keeps the downstream `Box3D` = centre±dims contract correct). See [[reference-vpe-tracking-research]].
