---
name: feedback_source_venv_before_build
description: Always source .venv before building or running anything in the VPE workspace — never build/run with only ROS sourced
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

In the `v5_vehicle_pose_estimator` workspace, **always `source .venv/bin/activate` FIRST, then `source /opt/ros/jazzy/setup.bash`, before any `colcon build` or e2e run** (`tools/run_investigation.sh`, `ros2 launch`).

**Why:** `open3d` and `small_gicp` live ONLY in `.venv` (the venv has `include-system-site-packages = false`). If you build/run with only ROS sourced, `ros2 launch` spawns the system Python (`/usr/lib/python3.12`), the tracking node dies with `ModuleNotFoundError: No module named 'open3d'` (via `vpe_utils → ros_conversions → import open3d`), `/segmented_cloud` never publishes, and `metrics.csv` comes out empty. The run script `tools/run_investigation.sh` already sources `.venv` internally, but the interactive build/run shell must too.

**How to apply:** Start every build/run command with `source .venv/bin/activate && source /opt/ros/jazzy/setup.bash && <colcon build | tools/run_investigation.sh ...>`. This is in addition to the env-stripped invocation used for unit tests. Relates to [[feedback_uv_toolchain_preferred]] and [[project_vpe_python_312]].
