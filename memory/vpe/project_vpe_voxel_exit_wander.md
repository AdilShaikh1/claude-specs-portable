---
name: project_vpe_voxel_exit_wander
description: VGICP exit X-wander on the Ioniq fixed by coarsening vgicp.voxel_resolution 0.10→0.20; other VGICP knobs are not levers
metadata: 
  node_type: memory
  type: project
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

At booth EXIT the visible cluster truncates to ~half the car (`obb_len` 3.4→2.0 m) and the leading-edge anchor is **extrapolated** from that partial rear cloud registered against the full locked CAD — so the registered leading-edge X **slides ±0.3 m** (the perception cluster X stays stable; it's a VGICP partial-registration artifact, NOT observability — the blind Hessian axis is Z, and the non-holonomic constraint is verified working: it forbids lateral *velocity*, not a measurement-injected position jump).

**Fix:** `vgicp.voxel_resolution` 0.10 → **0.20** in `tracking.yaml` — coarser VGICP voxels average over more points → smoother, more stable Gaussians → the truncated partial cloud registers consistently. Black/Ioniq exit X-wander **384 → 116 mm (3.3×)**, Tiguan **unregressed** (5 mm, containment 0.978), scored `body_xmax` unchanged. Deterministic (nt=1) sweep both bags: U-shaped vs voxel, floor at **0.20–0.25**; finer (≤0.05) DIVERGES; 0.30 reverses (Ioniq 333 mm). 0.20 chosen over 0.25 because 0.25 regresses the Tiguan (exit 5→34 mm) for no Ioniq gain.

**Other VGICP knobs are NOT levers** (all swept, both bags): `max_correspondence_distance` 0.10→1.00 flat; `downsampling_resolution` 0.06 is a local optimum (coarser worse/diverges, finer worse + latency); `reference_downsample_m` coarser degrades scored `body_xmax`. The source cloud is already 5 cm-quantized in perception (`downsample_voxel_size_m`) before VGICP, which caps VGICP-side downsampling.

The residual 116 mm is the tuning FLOOR — fundamental to extrapolating the leading edge from a half-truncated cloud; only in the unscored exit free-run zone (y>6). Related: [[project_vpe_obb_le_characterization]], [[project_vpe_tracking_leading_edge_reference]].
