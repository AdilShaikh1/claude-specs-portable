---
name: doc-authorship-adil-shaikh
description: "All docs authored in this workspace use \"Adil Shaikh\" in the Author metadata field — never \"VPE Development Team\" or other placeholders"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a7cc3703-1961-42be-9936-cc5737169d93
---

All docs in the `v5_vehicle_pose_estimator` workspace (handover docs, design docs, specs, package readmes if an author field is present) are authored under the name **Adil Shaikh**.

**Why:** Standing user preference. The placeholder "VPE Development Team" appeared in assistant-generated docs when no explicit author was specified — user is the actual owner of the work and wants attribution to reflect that.

**How to apply:**
- Any new doc created with an `**Author:**` or `Author:` metadata block uses "Adil Shaikh".
- When auditing or updating existing docs, normalise any "VPE Development Team" / similar placeholder author lines to "Adil Shaikh".
- Applies regardless of who actually generated the prose (assistant, subagent, copy-pasted template). The author field reflects ownership, not direct authorship of the text.
- Does NOT apply to docs outside this workspace, and does NOT apply to commit messages or PR descriptions (those follow [[feedback_no_assistant_attribution_in_commits]] — no attribution at all there).
