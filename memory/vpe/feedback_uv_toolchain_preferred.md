---
name: uv-toolchain-preferred
description: "Stick to uv (uv env / uv sync / uv add / uv run / .venv) for Python work; don't precede uv commands with env-stripping shells like `env -u VAR ... uv run`"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f1e37d28-a636-483f-b82e-0e1ffa868c50
---

For Python work in any of the user's projects, always use the `uv` toolchain
directly: `uv env`, `uv sync`, `uv add`, `uv run`, the `.venv/` directory.

**Why:** User's stated preference. They've standardized on uv across projects
and `uv run` already handles env isolation properly via the `.venv` —
prefixing with `env -u AMENT_PREFIX_PATH ... uv run pytest ...` (the
env-strip dance documented in some CLAUDE.md files) looks like fighting the
toolchain.

**How to apply:**
- **EVERYTHING runs under `.venv` in v5_vehicle_pose_estimator — not just
  pytest, but ROS node execution, `colcon`, and `ros2 launch` too.** Reinforced
  2026-05-27: "everything should always run under .venv for this project."
  The `.venv` is Python 3.12 (ABI-compatible with Jazzy's `rclpy` C extension),
  so with ROS sourced (ROS site-packages on PYTHONPATH for rclpy) + the install
  overlay sourced, `.venv/bin/python` can import BOTH `rclpy` AND the venv-only
  deps (`small_gicp`, `open3d`, `scipy`). Run nodes with `.venv/bin/python`,
  never system `python3`. This is also why venv-only runtime deps (e.g.
  `small_gicp` for vpe_tracking) resolve at node runtime.
- **Always go through the `.venv` directly for running code/tests:** prefer
  `.venv/bin/python -m pytest …` / `.venv/bin/<tool>` (this is the house style
  in the v5_vehicle_pose_estimator workspace — its CLAUDE.md verification
  examples use `.venv/bin/python -m pytest src/<pkg>/test -q`).
- Use `uv` for environment management: `uv sync`, `uv add`, `uv env`.
- Don't run bare `pytest` / `python` / `pip install` — never the system
  interpreter; always the `.venv`.
- Don't prefix calls with `env -u VAR ...` to scrub ROS / shell env. If ROS
  env contamination is a real problem in a particular shell, ask the user to
  open a clean shell rather than building the env-strip into every command.
- Project Makefile targets are fine to use as-is.
