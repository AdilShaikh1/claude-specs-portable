---
name: vpe-python-312
description: VPE workspace pins Python 3.12 — required for ROS Jazzy rclpy bindings; .venv must be 3.12 not 3.11
metadata: 
  node_type: memory
  type: project
  originSessionId: a7cc3703-1961-42be-9936-cc5737169d93
---

The VPE workspace at `/home/adil/degould_projects/v5_vehicle_pose_estimator` pins **Python 3.12** via `.python-version`. The `.venv` must be 3.12, not 3.11.

**Why:** ROS Jazzy ships `rclpy`'s C extension as `_rclpy_pybind11.cpython-312-x86_64-linux-gnu.so` — only loadable from Python 3.12. A 3.11 `.venv` (which was the previous pin) fails at runtime with `ModuleNotFoundError: rclpy._rclpy_pybind11` even after sourcing `/opt/ros/jazzy/setup.bash`. open3d 0.18+ supports 3.12 so the perception node's other deps (numpy, scipy, sklearn, open3d) are all happy on 3.12. Diagnosed 2026-05-18 during the vpe_perception smoke test.

**How to apply:**
- After `git clone` (or whenever the `.venv` looks broken), run `uv venv --python 3.12 --clear && uv sync --extra dev`. The `--python 3.12` is honoured because `.python-version` says `3.12` — if you ever see `Python 3.11.x` in `.venv/bin/python --version`, the pin file got reverted.
- For host-side ROS launches: `source /opt/ros/jazzy/setup.bash && source install/setup.bash && source .venv/bin/activate` (in that order). The 3.12 `.venv` provides numpy/scipy/sklearn/open3d while ROS provides rclpy.
- Unit tests can also use the 3.12 .venv directly: `.venv/bin/python -m pytest src/vpe_perception/test`.
- The Docker image (`ros:jazzy-ros-base`) already uses 3.12 — the host pin change brings dev parity with the image.
