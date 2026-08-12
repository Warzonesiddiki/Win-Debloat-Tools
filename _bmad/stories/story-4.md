# Story 4 — CLI, GUI, one-click

**Why:** The primary user will not assemble a script list.

**Do:** Presets Full/LowEnd/Win11/Safe. GUI buttons and toggles. `Win11-LowEnd.cmd`.

**AC:**
- `.\WinDebloatTools.ps1 LowEnd` sets override + full low-end list.
- Green button forces ExtremeLowEnd.
- Undo includes new scripts.
- cmd self-elevates.

**Files:** `WinDebloatTools.ps1`, `Win11-LowEnd.cmd`
