---
name: reference-vpe-tracking-research
description: External research and code references that informed the vpe_tracking package design (self-built Golden Map + VGICP + ESKF). Include in handover docs.
metadata: 
  node_type: memory
  type: reference
  originSessionId: 43e0b5b4-4d8a-4576-b4d1-e0cad1dc85c0
---

References to cite in `docs/VPE_Tracking_Handover_Document.md` and any spec under `docs/superpowers/specs/`.

## Reference prototype (origin of "VGICP + ESKF" + Golden Map concept)

- **DeGould/v5-vehicle-Tracking-lidar** — https://github.com/DeGould/v5-vehicle-Tracking-lidar
  - `helper_scripts/test_pipeline.py` — offline PCD-driven pipeline driver
  - `helper_scripts/ESKF_tracker.py` — `GoldenMap`, `MultiTrackESKF`, `ESKFConfig` (9D state in prototype)
  - `helper_scripts/ESKF_initialiser.py` — buffer-window initial-state estimator
  - `helper_scripts/gating_box.py` — DBSCAN + persistent-ID gating (replaced in our impl by perception's Tracker)
  - `helper_scripts/background_subtractor.py` — workzone-bounds bg subtractor (replaced by perception's OnlineBackgroundStage)
  - `helper_scripts/point_cloud_validator.py` — offline shape-accumulation validator (folded into our snapshot.py)

## Research papers

- **Pang et al., 2021 — "Model-free Vehicle Tracking and State Estimation in Point Cloud Sequences"** (LiDAR_SOT / SOTracker)
  - Paper: https://arxiv.org/abs/2103.06028
  - Code: https://github.com/TuSimple/LiDAR_SOT
  - Key idea: shape completion by overlaying point clouds as a by-product of tracking; aggregates aligned scans over the entire tracklet
  - Relevance: validates "self-built shape model from streaming scans" as a viable model-free approach; informed our continuous rolling-window map decision
  - Caveat: their tracker is **batch / non-causal optimization**, not a Kalman filter — we use causal ESKF instead

- **Gu, Liu et al., 2021 — "ECPC-ICP: A 6D Vehicle Pose Estimation Method by Fusing the Roadside Lidar Point Cloud and Road Feature"** (MDPI Sensors)
  - Paper: https://www.mdpi.com/1424-8220/21/10/3489 / https://pmc.ncbi.nlm.nih.gov/articles/PMC8156169/
  - Pipeline: RANSAC road plane + PCA on cluster → coarse 6D pose → point-to-point ICP refinement against template
  - Real-world numbers: **2.6% position error / 1.64° orientation / 53.19 ms (18.8 fps)** — these inform our verification-harness PASS/SUSPECT thresholds (<3 cm position, <2° orientation, <50 ms tick)
  - No public code

- **Engelmann et al., 2020 — "Joint Pose and Shape Estimation of Vehicles from LiDAR Data"** — https://arxiv.org/pdf/2009.03964 (additional reading on shape+pose joint estimation; not directly ported)

## Companion implementations

- **koide3/small_gicp** — https://github.com/koide3/small_gicp
  - Header-only C++ with Python bindings; `pip install small-gicp`
  - Voxelized GICP at 30 FPS CPU on HDL32e clouds in published benchmarks
  - Used for the scan-to-self-built-map registration step

- **LimHaeryong/ESKF_LIO** — https://github.com/LimHaeryong/ESKF_LIO
  - ESKF + VGICP architecture pattern (for LiDAR-IMU odometry, not target tracking)
  - Confirms ESKF+VGICP as a real architecture; useful for ESKF math reference

- **rsasaki0109/lidarslam_ros2** — https://github.com/rsasaki0109/lidarslam_ros2
  - ROS2 NDT/GICP pose-graph SLAM
  - Reference for wrapping GICP in a ROS2 node (subscription / publication / parameter declaration patterns)

## Foundational references

- "Quaternion kinematics for the error-state Kalman filter" — Solà 2017 (https://arxiv.org/abs/1711.02508) — standard ESKF reference; cited by DeGould prototype's ESKF_tracker.py docstring

- Koide et al., ICRA 2021 — "Voxelized GICP for Fast and Accurate 3D Point Cloud Registration" — https://staff.aist.go.jp/shuji.oishi/assets/papers/preprint/VoxelGICP_ICRA2021.pdf — VGICP original paper

## Drift investigation (2026-05-27) — motion-onset lag + golden-map maintenance

Context: e2e on `booth_test_slow_bag` showed the tracked origin lagging the leading edge **as the car accelerates from rest** (real-bag `le_align` grew while `vy` ramped 0→0.7), and the golden map only ever *adds* points (no noise/ghost trimming). Constraint: too little granularity (sparse ~10 Hz, noisy) to estimate an acceleration state reliably.

### Motion-onset lag in a constant-velocity (CV) filter — handle WITHOUT an acceleration state
- **Nearly-Constant-Velocity (NCV) / white-noise-acceleration model:** acceleration is *not* a state — it is absorbed as process noise on velocity (our `q_vel`). The steady-state lag during a maneuver is governed by the q/r (process/measurement) bandwidth ratio; raising `q_vel` (or lowering `r_pos`) shrinks the lag.
  - "MSE Design of Nearly Constant Velocity Kalman Filters for Tracking Targets With Deterministic Maneuvers" — IEEE TSP, https://ieeexplore.ieee.org/document/10032801/
  - MathWorks "Tuning Kalman Filter to Improve State Estimation" — https://www.mathworks.com/help/fusion/ug/tuning-kalman-filter-to-improve-state-estimation.html
- **Adaptive / dynamic process noise:** detect the maneuver online (innovation magnitude / measured average acceleration) and inflate Q during transients, keep it tight when cruising — low lag during accel + low jitter at constant speed, no extra state.
  - "Kalman Filter With Dynamical Setting of Optimal Process Noise Covariance" — IEEE Access 2017, https://ieeexplore.ieee.org/document/7914658/ , https://www.researchgate.net/publication/316569528
- **IMM (Interacting Multiple Model):** run CV + CA (+ constant-turn) in parallel, Bayesian-weight by residual — the textbook maneuvering-target answer, but a CA member still needs an acceleration model (the granularity we lack); heavier.
  - MathWorks "Tracking Maneuvering Targets" — https://www.mathworks.com/help/fusion/ug/tracking-maneuvering-targets.html
  - IMM-MOT (3D MOT w/ IMM), 2025 — https://arxiv.org/html/2502.09672v1
  - `trackingIMM` — https://www.mathworks.com/help/fusion/ref/trackingimm.html
- **Decision:** prefer NCV with tuned/adaptive `q_vel` (no acceleration state), validated on the real bag — matches the "not enough granularity for acceleration" constraint.

### Occlusion-aware map maintenance — trim noise WITHOUT deleting the occluded/exited front
Core principle from the dynamic-point-removal literature: only remove a point when its space is **confirmed not-belonging** (observed-free / outside the object), **never** merely because it is absent from the latest scan (it may be occluded).
- **FreeDOM (free-space carving):** clear only voxels observed free *both temporally and in a spatial neighborhood* — avoids false positives from transient occlusion (the exact failure mode of deleting the occluded front).
- **ERASOR** — Egocentric Ratio of Pseudo-Occupancy, RA-L 2021 — https://arxiv.org/pdf/2103.04316
- **Removert (Remove-then-Revert)**, IROS 2020 — https://gisbi-kim.github.io/publications/gkim-2020-iros.pdf — visibility via range images; *fails behind persistent occluders* (cautionary: visibility-only over-deletes occluded points)
- **A Dynamic Points Removal Benchmark in Point Cloud Maps**, 2023 — https://arxiv.org/pdf/2307.07260 ; survey: https://www.emergentmind.com/topics/dynamic-points-removal
- **System-specific option (leverages our good perception OBB):** gate the map by the *tracked canonical vehicle box* (running-max `vehicle_dims` at the tracked pose, + margin) — keep points inside (incl. the occluded/exited front, which is inside the box), trim ghosts/noise outside. Occlusion-safe because the box bounds the whole car, not just the visible slice. (Do NOT crop to the per-frame *visible* OBB — that would delete the accumulated occluded parts.)
- Pang 2021 (above) reinforces aggregating aligned scans for shape completion; our addition is the *trimming* half they don't emphasize.
