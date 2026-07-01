---
name: feedback_tmp_under_internal
description: "Store scratch/tmp files under INTERNAL/tmp/<subfolder>/, never /tmp"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

In the v5_vehicle_pose_estimator workspace, write all scratch/throwaway files (run logs, console-echo captures, debug dumps) under `INTERNAL/tmp/<subfolder>/` — NOT `/tmp`. `INTERNAL/` is gitignored (`.gitignore` line 40 `/INTERNAL`), so `INTERNAL/tmp/` is safely deletable and stays out of git.

**Why:** the user can't easily see or clean `/tmp`; littering it with `c1_*.log` etc. is invisible and untidy. Keeping scratch under `INTERNAL/tmp/` makes it visible in the IDE and trivially purgeable.

**How to apply:** redirect background-run logs to `INTERNAL/tmp/<task>/run.log`; organise per-purpose subfolders; treat everything there as deletable. The real run artifacts already live under `INTERNAL/diagnostics_runs/` and `INTERNAL/init_phase_eval/<ts>/` — the tmp log is just the redundant console echo. Related: [[feedback_always_fresh_e2e]].
