---
name: feedback-recognize-car-in-snapshots
description: "When reading perception phase snapshots (lidar topdown / side / front views), always identify the actual vehicle in the point cloud and verify the OBB against it concretely. Do not produce generic interpretations like \"dense cluster at Y=[-3,-1]\" without saying what part of the car that is."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a7cc3703-1961-42be-9936-cc5737169d93
---

Rule: When verifying perception output via the phase-snapshot PNGs, **identify the actual car** in the point cloud first — its position, orientation, length, width, height, which side is facing where, what shape its returns form — and compare the OBB to that recognised geometry concretely. Do not give generic shape-of-cluster interpretations.

**Why:** [[feedback_perception_e2e_verification]] established that e2e + visual verification is mandatory after perception changes. But "visual" without "identify the car" devolves into describing the *cluster* as if it's the ground truth — which misses cases where the cluster is fitting the wrong object (booth + car merged, or just booth alone). The user (Adil) raised this after I described a snapshot as "dense arc pattern at Y=[-3, -1]" without saying "the car appears to be at X=[1, 2.5], Y=[-2.5, -1] in this frame" or comparing the OBB's actual coverage to the car's actual footprint.

**How to apply:**

When reading a snapshot, before writing any analysis:
1. **Locate the car.** Where in the work zone is it? Use the dense / structured portion of the point cloud, not just any cluster. Cars are 4-5m long × 1.7-2m wide × 1.4-2m tall.
2. **Identify orientation.** Which way is the car facing? In a booth, vehicles typically drive along the long axis (Y in the VPE booth). Compare to what the OBB shows.
3. **Compare OBB to car geometry.** Does the OBB tightly enclose the car? Or does it extend beyond the car into empty / booth-structure space? Is its rotation consistent with the car's facing direction?
4. **In side (YZ) view:** look for the height profile. A car has a flat roof at ~1.4–1.8m, hood at ~1.0m, windscreen sloped. Vertical features in YZ above the roofline mean booth structure, NOT the car.
5. **In front (XZ) view:** width should be ~1.7–2m. A vertical feature wider than that is multiple things merged.
6. **Express findings concretely:** "the car is at X=[1.2, 2.4], Y=[-2.8, -1.2], facing +Y; the OBB extends to Y=0 which is 1.2m past the car's nose, suggesting it's bridged to booth structure at Y≈-0.3." Not "the cluster is bloated and the OBB is too big."

If I cannot locate the car (e.g., bag is during entry/exit, or pipeline isn't detecting it), state that explicitly and reason about WHY rather than describing the cluster generically.

**Critical extension (from feedback received this session): make inferences, don't just describe.** Stating "the cluster is at X=[0.8, 2.8], Y=[-2.3, -1.7]" is description. Stating "the cluster is 1.8 m wide × 0.6 m long, but a car is 4–5 m long, and there are clearly gray foreground points extending beyond the cluster's Y bounds — *the cluster is missing more than half the vehicle*" is inference. The user pointed out that visual verification has no value if I describe geometry without reasoning about what the geometry means relative to the expected vehicle shape.

Specific inferences I should be making automatically from each view:

- **Top view**: If the blue cluster's footprint is < car-sized (4 m × 1.7 m typical) AND gray foreground points exist outside it, the cluster is fragmented — likely a `cluster_voxel_size_m` regression splitting the vehicle.
- **Side view**: If the blue cluster's Y-span is < ~3 m AND gray foreground points extend beyond, the cluster is missing the front or rear of the vehicle.
- **Side view (Z range)**: If Z extends > 2 m, that's not a car — that's booth structure. Even hood-to-roof for an SUV is < 2 m.
- **Front view**: If X-span is > 2 m, the cluster is too wide for one car — bridging into booth structure or adjacent vehicles.

Always cross-reference the three views: gray points in side view that aren't in top view (or vice versa) tell me the cluster's Z-distribution differs from the X/Y distribution, which usually means one view has stragglers that the cluster missed or included.

Out of scope: non-vehicle test data (synthetic blobs, unit-test inputs). This rule is specifically for booth-bag visual verification.

Related: [[feedback_perception_e2e_verification]] (e2e + visual gate), CLAUDE.md "Verifying perception changes" section.
