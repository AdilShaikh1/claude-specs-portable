---
name: vpe-sensor-naming
description: "VPE LiDAR sensor naming convention — JT_SL/JT_T/JT_SR matches calibration filenames, replaces old JTLidar1/2/3 placeholders"
metadata: 
  node_type: memory
  type: project
  originSessionId: a7cc3703-1961-42be-9936-cc5737169d93
---

VPE LiDAR sensors use the names **JT_SL** (side-left), **JT_T** (top), **JT_SR** (side-right). These match the calibration filenames at `INTERNAL/JT_{SL,T,SR}_calibration.json` in `/home/adil/degould_projects/v5_vehicle_pose_estimator`. The corresponding PointCloud2 topics are **singular**: `/JT_SL_pointcloud`, `/JT_T_pointcloud`, `/JT_SR_pointcloud` (this matches both `INTERNAL/booth_test_slow_bag` and the Hesai driver output).

Physical layout (booth ≈3.4m wide along x):
- JT_SL: side-left,  x≈0.07
- JT_T:  top,        x≈0.28, z≈1.90 (highest)
- JT_SR: side-right, x≈3.36

**Hardware sync:** The three LiDARs are PTP-synced (sub-ms clock jitter) and fire in a deliberate staggered phase pattern: T leads SL by ~23 ms (±0.7 ms), SR by ~61 ms (±0.5 ms). Per-sensor rate is 10 Hz (100 ms period). The full per-frame spread is ~61 ms. Consequence for perception config: `sync_tolerance_ms` must clear 61 ms to fuse all three sensors — the working value is **80 ms** (margin on the spread, but still under the 100 ms period to avoid catching adjacent frames). The original placeholder value `sync_tolerance_ms: 5.0` was incompatible with this hardware and caused `/segmented_cloud` to stay empty.

**Why:** Renamed during the vpe_preprocessing+vpe_segmentation→vpe_perception merge (2026-05-18) so sensor identifiers in `perception.yaml` / `sensor_transforms.yaml` match the calibration source files. The previous `JTLidar1/2/3` names were placeholder values from before the calibration files were canonical. The sync_tolerance value was diagnosed during the same session by mcap-reading the bag's recorded header.stamp values.

**How to apply:**
- When editing perception config (`src/vpe_launch/config/perception.yaml`) or vpe_tf config (`src/vpe_launch/config/sensor_transforms.yaml`), use `JT_SL`/`JT_T`/`JT_SR` and the matching **singular** topic names.
- Transform values come from `INTERNAL/JT_*_calibration.json` → `T_lidar_to_world` 4x4 → quaternion via `scipy.spatial.transform.Rotation.from_matrix(R).as_quat()` (returns `[x, y, z, w]`, the exact order ROS expects).
- If you spot `JTLidar1/2/3`, plural `*_pointclouds`, or `sync_tolerance_ms` < 65 in src/ or docs/, it's stale and should be migrated.
