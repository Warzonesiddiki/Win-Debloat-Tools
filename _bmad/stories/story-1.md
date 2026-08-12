# Story 1 — Hardware profile engine

**Why:** A 4 GB HDD PC and a 32 GB NVMe PC cannot share one service list.

**Do:** Implement `Resolve-HardwareProfile` and `Get-HardwareProfile`. Export flags: DisableSysMain, DisableSearch, AggressiveVisuals, UseCompactOS, DisableHibernate, EnableHAGS, PagefileStrategy.

**AC:**
- Thresholds match `tests/test_hardware_profile.py`.
- Override via `WIN_DEBLOAT_PROFILE_OVERRIDE`.
- Protected service list includes WinDefend, wuauserv, Audiosrv, WlanSvc, Spooler.

**Files:** `src/lib/Get-HardwareProfile.psm1`, `tests/test_hardware_profile.py`
