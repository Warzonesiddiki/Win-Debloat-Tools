# Story 2 — Windows 11 AI and shell

**Why:** 24H2/25H2 put Copilot, Recall, Widgets, and Click to Do on machines that cannot afford them.

**Do:** `Windows11-Tweaks.psm1`, `Optimize-Windows11.ps1`, `Disable-WindowsAI.ps1` with full enable/disable pairs.

**AC:**
- Copilot policy + AppX + Edge sidebar.
- Recall AllowRecallEnablement=0 and optional feature off.
- SilentInstalledApps blocked.
- `$Revert` restores policies (does not silently reinstall Store apps).

**Files:** `src/utils/Windows11-Tweaks.psm1`, `src/scripts/Optimize-Windows11.ps1`, `src/scripts/Disable-WindowsAI.ps1`
