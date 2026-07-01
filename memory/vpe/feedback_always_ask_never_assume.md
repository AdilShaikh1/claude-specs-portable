---
name: feedback_always_ask_never_assume
description: Always ask clarifying questions before implementing; never proceed on an assumption
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 43e0b5b4-4d8a-4576-b4d1-e0cad1dc85c0
---

ALWAYS ask clarifying questions and NEVER assume things — especially design details, root causes, formulas, and "is this good enough" judgments. When any detail is uncertain, stop and ask via AskUserQuestion before writing code or drawing a conclusion.

**Why:** repeated assumptions caused wasted cycles and wrong conclusions on the VPE tracking work — e.g. assuming the body-frame origin came from a 99th-percentile rule on cluster points (it should come from the cluster **OBB**), assuming the exit `le_align` excursion was benign, assuming adaptive-`q` would fix the gentle-ramp lag, and calling the entry frames "tight" when there was a systematic bias. Each assumption the user had to catch and correct.

**How to apply:** if you catch yourself writing "I assume", "presumably", "should be", or concluding from a few samples — stop and ask instead. Verify on the real bag and across ALL frames ([[feedback_debug_with_real_bag]], [[feedback_perception_e2e_verification]]), and confirm formulas/definitions with the user before coding. Surface uncertainty explicitly rather than papering over it.

**Do ONLY what you are told — don't bundle adjacent changes** (reinforced, v5-hesai-lidar-monitor dashboard): asked to "make it fully light", I also lightened the **Live point cloud**, but a point cloud belongs on a **dark** background. When a request (or an AskUserQuestion option) bundles several effects, confirm each panel/scope separately rather than assuming the whole bundle is wanted; make the smallest change that satisfies the literal instruction and ask before extending it.

**NEVER state an interpretation/conclusion as fact until it is fact-checked and you are 100% sure** (user demand, explicit — VPE black-bag tracking debug). A whole session of premature conclusions had to be overturned ONE BY ONE by the user: "front-only yaw is unobservable" (WRONG — perception extracts it sub-deg), "the yaw constraint comes from the side panel" (WRONG — the front contains it, VGICP's surface cost just can't read it), "VGICP tuning is a dead end" (WRONG — voxel 0.25 fixed it; I broke it myself with a bad iter-50 move then over-generalized one failed run), and a guessed "37-39 s → frame" time-mapping + "forward-blind exit" read asserted as if established. **How to apply:** treat every analysis output as a hypothesis, not a verdict; verify it against the real data/code BEFORE writing it down; when you can't verify, say "I don't know / not verified" explicitly rather than filling the gap with a plausible story; do NOT declare victory OR defeat (no "this works"/"dead end"/"root cause is X") from a single run or a partial test. One contradicting data point from the user means STOP and re-verify, don't defend.
