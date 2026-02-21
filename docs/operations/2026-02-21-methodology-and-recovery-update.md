# 2026-02-21 Update: Methodology Automation + Gateway Recovery

This update captures two practical improvements validated in daily OpenClaw usage.

## 1) Automatic methodology triggering

A lightweight pattern-routing layer was added to reduce inconsistent responses.

### What it does
- Routes **comparison/advice/current-facts** prompts to a **research-first** flow.
- Routes **implementation/debug/architecture** prompts to a **senior-engineering** flow.
- Leaves simple prompts on standard flow.

### Why it helps
- Prevents “answering from memory” on questions that need fresh evidence.
- Enforces a repeatable OBSERVE → ISOLATE → FIX + VERIFY structure for technical tasks.

### Notes
- This is deterministic trigger routing, not hidden magic.
- Pattern lists should be tuned over time with real prompts.

---

## 2) Gateway restart recovery workflow for WSL2

A restart-safe operational flow was documented and scripted for environments where systemd/user supervision is limited.

### Operational additions
- A restart wrapper with post-restart checks
- A quick health-check command for immediate validation
- Clear token/session health checks after restart

### Why it helps
- Faster detection of broken reconnect states
- Better visibility into “gateway up but session unhealthy” cases
- Fewer silent failures after restarts

---

## Implementation takeaway

Turning methodologies into **automatic defaults** improves reliability more than writing more rules. 
The biggest gains came from:
1. deterministic trigger routing,
2. minimal operational scripts,
3. explicit verification after each critical action.
