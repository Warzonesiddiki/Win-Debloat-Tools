# Architecture — Windows 11 Low-End Edition

## Decision records

### ADR-1: Extend the existing PowerShell GUI instead of a rewrite
**Context:** The archived project already has revert, logging, helpers, and a WinForms GUI.  
**Options:** (1) Rewrite in C#/WinUI (2) Adopt Raphire's script as the core (3) Extend this repo.  
**Choice:** (3). Shipping a 4 GB-friendly product this week requires the chassis we have.  
**Reject:** (1) too slow; (2) loses this GUI and software-install tab.

### ADR-2: Profile function is pure and tested off-Windows
**Choice:** `Resolve-HardwareProfile` takes numbers. Python tests clone the thresholds for Linux CI.  
**Reject:** Pester-only (CI is Ubuntu).

### ADR-3: Never default-disable HVCI / Defender / Update
**Choice:** Performance that depends on turning off memory integrity is opt-in.  
**Reject:** "gamer script" defaults.

### ADR-4: Force ExtremeLowEnd via env vars, not a second code path
**Choice:** `WIN_DEBLOAT_PROFILE_OVERRIDE` + `WIN_DEBLOAT_FORCE_AGGRESSIVE`. Scripts stay one function.

## Layers

```
WinDebloatTools.ps1          CLI/GUI entry, preset lists
Win11-LowEnd.cmd             one-click elevate → LowEnd
src/lib/Get-HardwareProfile  classify + protected services
src/lib/Save-TweakState      startup backup JSON
src/utils/Windows11-Tweaks   enable/disable pairs
src/scripts/Optimize-*       pipeline steps (imported by GUI, -File by CLI)
src/scripts/Disable-WindowsAI
tests/test_hardware_profile  CI
```

## Data

- `%LOCALAPPDATA%\Win-Debloat-Tools\startup-backup.json`
- Logs: `%LOCALAPPDATA%\Temp\Win-DT-Logs`
- Restore points: System Restore

## Security

Protected service list in `Get-ProtectedServiceList`. New disable lists must not include those names.

## Observability

`Show-SystemHealth.ps1` reports profile, RAM, disk, Copilot/Recall/Widgets, SysMain, Search, HVCI.
