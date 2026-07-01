---
name: feedback_prefer_simplest_alternative
description: "Don't over-engineer — check for a simpler, more straightforward alternative first and lead with it"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09b79f3d-79fa-4a66-be35-5ee8a632f5cb
---

Don't over-engineer concepts. Before proposing or building anything, actively check whether a simpler,
more straightforward alternative already exists — an existing config flag/param, already-published
data/topics, an off-the-shelf tool, or a small reuse of an existing package — and lead with that.

**Why:** Asked for the *simplest* way to visualise the perception+tracking pipeline, I jumped to designing
a new Rerun bridge node + a throttled golden-map publisher + a 4-option fork — when the pipeline already
publishes most of the data (`/segmented_cloud` with clouds+OBBs, `/vehicle_pose`, `/diagnostics`), an
existing Rerun viz (`vpe_debug`) was available, and `ros2 bag record` + an off-the-shelf viewer would have
covered it with zero new code. The user wants the least-effort path that works, not the most complete
architecture.

**How to apply:** Lead with the simplest option that meets the requirement; escalate to new infrastructure
only when the simple path genuinely can't do it. Preference order: existing flags/params > already-
published data/topics > off-the-shelf tools (e.g. `ros2 bag record`, foxglove_bridge) > small reuse of an
existing package > new code/nodes. Surface the simple alternative even when a bigger build feels
"cleaner". When unsure whether the simple path suffices, ask rather than assume the big build is needed
([[feedback_always_ask_never_assume]]).
