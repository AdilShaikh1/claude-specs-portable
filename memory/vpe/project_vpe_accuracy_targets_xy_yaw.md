---
name: project_vpe_accuracy_targets_xy_yaw
description: VPE pose accuracy targets are X/Y/yaw only — Z (height) is not evaluated or tuned for
metadata: 
  node_type: memory
  type: project
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

The published-pose accuracy goal is per-frame error <10 mm in **X (lateral)** and **Y (travel)** plus **yaw <0.2°**. **Z (height) is explicitly out of scope** — user 2026-06-25: "we dont care about Z we only care about X and Y and yaw". The compare gate's published-pose verdict already reflects this (it scores X/Y/yaw rows, no Z row).

The `work_zone_min` Z floor crop (tuned live 0.040→0.080→0.1 m on 2026-06-25) is a **cluster-hygiene** knob (reject floor noise), NOT a Z-accuracy lever — but note raising it correlated with a worse leading-edge `le_align` (pose trails the live scan's front: -0.20 m @ Z=0.08 → -0.25 m @ Z=0.1, small n), plausibly because cropping the low/most-forward front points shifts the detected leading edge back along the sloped front.

When working the leading-edge / pose-lag accuracy gap ([[project_vpe_obb_le_characterization]]), optimise X/Y/yaw and ignore Z. See [[project_vpe_tracking_leading_edge_reference]].
