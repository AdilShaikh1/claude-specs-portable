---
name: feedback-perception-e2e-verification
description: "After any perception/pipeline change in the v5_vehicle_pose_estimator workspace, ALWAYS run the full end-to-end pipeline against booth_test_slow_bag AND visually inspect the result (now via Foxglove on a recorded MCAP) before declaring the change complete. Unit tests + colcon build are necessary but not sufficient."
metadata:
  node_type: memory
  type: feedback
  originSessionId: a7cc3703-1961-42be-9936-cc5737169d93
---

Rule: After every change to `vpe_perception` (or anything that affects the perception/tracking pipeline output: stages, tracker, classifier, yaml params, work zone), run the **full e2e pipeline against `INTERNAL/booth_test_slow_bag` with visual confirmation** before claiming complete or asking the user to review. Unit tests + colcon build pass on every "compiles + matches spec" change — they do not detect geometric corruption, parameter mis-wiring, or behavioural regressions visible only on real data.

**Why:** [[feedback_test_before_docs]] established that tests gate docs. This extends it: e2e + visual gates the "complete" claim. Surfaced after a 7-task refactor was marked "done" on unit tests + build alone, never run against a bag.

**How to apply (updated 2026-06-25 — in-loop PNG snapshots were REMOVED; visualisation is Foxglove-only):**

1. `source .venv/bin/activate && source /opt/ros/jazzy/setup.bash && source install/setup.bash`; `colcon build --packages-select <changed pkgs> vpe_launch` (launch reads the INSTALLED yaml — rebuild `vpe_launch` after any yaml/launch edit).
2. Run the unified harness: `tools/run_investigation.sh booth_test_slow_bag --cad-eval --record` (perception + tracking + init-eval in ONE pass; `--cad-eval` for the scan→CAD accuracy gates, `--record` for the Foxglove MCAP). Output under `INTERNAL/diagnostics_runs/<ts>/`. See [[feedback_always_fresh_e2e]] + [[feedback_run_e2e_after_every_change]] + [[feedback_always_production_config_e2e]].
3. **Numerical:** check the compare gates / `scan_vs_cad` / `body_xmax` (PRIMARY origin-drift, target <10 mm X/Y) + `metrics.csv`. Accuracy targets are X/Y/yaw only — see [[project_vpe_accuracy_targets_xy_yaw]].
4. **Visual (now Foxglove, NOT phase-snapshot PNGs):** open the recorded `recording/*.mcap` in Foxglove Studio + import `tools/foxglove/vpe_tracking_layout.json` → recognise the car, inspect the segmented cloud / OBBs / golden map / pose / sensor-mask / diagnostics. (The old in-loop topdown-PNG `snapshot_dir` path was deleted; `tools/render_recording.py` was also removed.)
5. Only AFTER both axes look right, claim complete.

**Out of scope:** docs-only / config-only changes that demonstrably can't affect runtime geometry. Anything touching stages, the tracker, fit functions, or numerical params needs the full e2e.

Related: [[feedback_test_before_docs]], [[feedback_recognize_car_in_snapshots]], CLAUDE.md "Verifying changes".
