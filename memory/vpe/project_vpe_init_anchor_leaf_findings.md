---
name: project_vpe_init_anchor_leaf_findings
description: VPE init-map accuracy — the +93mm anchor was a metric artifact; real anchor ~6mm; leaf size is not the lever
metadata: 
  node_type: memory
  type: project
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

VPE init-map (slow bag) accuracy findings, 2026-06-18 (eval = `tools/eval_map_vs_cad.py`, now OBB-leading-edge based):

- The old "POSE/ANCHOR +93mm forward-Y" was a **measurement artifact**: it compared `percentile(Y,99)` of map vs CAD, but the densely-tapered CAD nose puts its 99th-pct ~78mm *behind* the true front face (CAD true front = +6.1mm via max-Y). Replaced with the LIVE `fit_l_shape`→`obb_leading_edge` derivation applied identically to both clouds (see [[project_vpe_tracking_leading_edge_reference]]).
- **Tracker reported anchor (0,0,0) is within ~6mm of CAD truth** (Y −6.1mm), stable across leaf sizes — well inside the ±10mm target. The anchor was never the problem.
- The real residual is a **~22mm forward-Y bulge of the reconstructed front vs the CAD front** (map front ~+28mm, CAD +6mm). This is a reconstruction/accumulation (or CAD-vs-real-bumper-seating) matter — target it with Phase C grow-only map / calibration, NOT leaf tuning.
- **Leaf size is NOT the lever.** Fresh e2e: 20mm leaf → fwdY +22.3mm, XY-RMS 11.2mm; 10mm leaf → fwdY +24.4mm (slightly WORSE), XY-RMS 11.3mm (same). Offline 5–40mm sweep flat at ~21.5mm. 20mm stays the choice (fewer voxels, same accuracy). Don't re-run leaf sweeps expecting accuracy gains.
- XY footprint reconstruction is good: p50 3.7mm, 88% ≤10mm, 0.7% contamination.

**Why:** repeatedly tempted to tune leaf/gap for accuracy; proven immaterial. **How to apply:** when chasing init-map XY/Y accuracy, look at registration/accumulation + CAD seating, not voxel resolution; trust the OBB-leading-edge metric over the legacy percentile proxy.
