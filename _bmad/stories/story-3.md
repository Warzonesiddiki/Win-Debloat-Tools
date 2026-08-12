# Story 3 — Low-end smoothness passes

**Why:** Visuals, Superfetch, indexer, pagefile, and startup helpers are the remaining tax after AI is gone.

**Do:** Visual effects, memory/CompactOS, startup backup, LowEnd orchestrator. Honor ForceAggressive.

**AC:**
- Font smoothing stays on.
- Memory Compression stays on.
- Startup removals written to `%LOCALAPPDATA%\Win-Debloat-Tools\startup-backup.json`.
- Hibernate only auto-disabled on desktops that are Extreme or critically low on disk.

**Files:** `Optimize-VisualEffects.ps1`, `Optimize-Memory.ps1`, `Optimize-StartupApps.ps1`, `Optimize-LowEndPC.ps1`, `Save-TweakState.psm1`
