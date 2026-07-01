---
name: never-reindex-bags-without-permission
description: "Never run `ros2 bag reindex` (or any equivalent reindex operation) without explicit user permission, even on a copy"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: acae045d-dda2-4c92-ba1e-010c13e29583
---

Never run `ros2 bag reindex`, `rosbag2_py.Reindexer`, or any equivalent operation that rewrites a bag's `metadata.yaml` or `.mcap` index without explicit user permission. This applies even for "just on a copy" or "just to see what it does."

**Why:** Reindex overwrites `metadata.yaml` based on what the storage plugin can currently read. When the storage plugin can't read the full bag (e.g. truncated `.mcap`, missing footer index), reindex silently rewrites the manifest with the *readable subset's* duration and message count — destroying the original recording's intended manifest. Once overwritten there's no way to know how many messages were *meant* to be in the bag. Triggered after I proposed reindex as a verification step on `INTERNAL/booth_test_slow_bag` without authorization.

**How to apply:** When considering ANY bag manipulation that touches `metadata.yaml` or rewrites bag storage, stop and ask first. This includes `ros2 bag reindex`, `ros2 bag convert`, manual edits to `metadata.yaml`, anything that calls `rosbag2_py.Reindexer`, and any Python script that opens the bag for writing. Read-only inspection (`ros2 bag info`, `ros2 bag play`, `mcap.stream_reader.StreamReader` for reading) is fine. When debugging bag issues, prefer reading the `.mcap` file record-by-record with the Python mcap library (e.g. `StreamReader` from `.venv/lib/python3.12/site-packages/mcap/stream_reader.py`) — it's authoritative, non-destructive, and reveals discrepancies between `metadata.yaml` and actual file contents (see [[project-vpe-bag-metadata-can-lie]]).

This rule is also written into the workspace's CLAUDE.md under "Hard rules" for visibility to any Claude instance working in this repo.
