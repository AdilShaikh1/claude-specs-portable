---
name: feedback_debug_with_real_bag
description: "Always debug VPE perception/tracking with real bag values, never synthetic reproductions"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 43e0b5b4-4d8a-4576-b4d1-e0cad1dc85c0
---

When diagnosing a VPE perception/tracking issue, debug against the **real `INTERNAL/` bag**, not a synthetic reproduction. Instrument the real node/tracker (temp CSV columns or probes) and re-run the bag; read the actual recorded values.

**Why:** synthetic models silently omit the real failure mode. Concrete miss: a constant-velocity synthetic "car" showed zero origin drift, hiding the real cause — the vehicle starts from **rest and accelerates**, and the constant-velocity ESKF lags during that ramp (the real bag's `le_align` grew exactly as `vy` ramped 0→0.7). The synthetic wasted a cycle and pointed at the wrong hypotheses.

**How to apply:** reach for the real bag + temp instrumentation first; only consider a synthetic to isolate one variable *after* the real-bag behaviour is understood, and say so explicitly. Pairs with [[feedback_perception_e2e_verification]] and [[feedback_recognize_car_in_snapshots]].
