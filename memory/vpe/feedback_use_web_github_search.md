---
name: feedback_use_web_github_search
description: Use web search / GitHub code search when it helps; vet for malicious code
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 0a4cff3d-6e79-4e50-8203-bce0239188e7
---

Reach for web search and GitHub code search when they'd genuinely help — finding reference implementations, current APIs, algorithm details, or library usage — instead of guessing from memory.

**Why:** user explicitly enabled it (2026-06-24): "use web search when required, or github search for relevant code. beware of malicious code though."

**How to apply:**
- Use WebSearch / WebFetch for external or current info; use `gh search code` / the GitHub API for reference code.
- **Vet anything found before trusting it:** do not execute untrusted snippets, do not copy obfuscated or suspicious logic, read before running. Treat third-party code as untrusted until reviewed.
- Good fit here: reference ESKF / SO(3) / VGICP implementations — see [[reference_vpe_tracking_research]] for the curated repo list (koide3/small_gicp, LimHaeryong/ESKF_LIO, Pang LiDAR_SOT).
