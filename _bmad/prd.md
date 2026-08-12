# PRD — Windows 11 Low-End Smoothness

## Epics

### E1 — Hardware profile engine
- **S1.1** `Resolve-HardwareProfile` classifies ExtremeLowEnd / LowEnd / MidRange / HighEnd from RAM, cores, media, free disk, laptop flag.
- **AC:** 4 GB HDD → Extreme; 8 GB SSD → Low; 16 GB SSD → Mid; 32 GB NVMe → High; override env works.
- **S1.2** Unit tests in Python + optional Pester file.

### E2 — Windows 11 AI and shell
- **S2.1** Disable Copilot (policy + AppX + Edge sidebar).
- **S2.2** Disable Recall (AllowRecallEnablement=0, DisableAIDataAnalysis=1, optional feature).
- **S2.3** Disable Click to Do, Widgets, Start Recommended, Gallery/Home.
- **S2.4** Disable Edge/Paint/Notepad AI and WSAIFabricSvc auto-start.
- **AC:** Each disable has a matching enable; Undo Tweaks calls `-Revert`.

### E3 — Low-end performance
- **S3.1** Visual effects: best performance + font smoothing + thumbnails.
- **S3.2** Memory: SysMain/Search by profile, pagefile, CompactOS, Storage Sense, no ClearPageFile.
- **S3.3** Startup bloat removal with JSON backup.
- **S3.4** LowEnd orchestrator: background apps, timeouts, prefetch, delivery optimization.

### E4 — Product surface
- **S4.1** CLI: `CLI` `LowEnd` `Win11` `Safe`.
- **S4.2** GUI buttons + six new checkboxes + System Health.
- **S4.3** `Win11-LowEnd.cmd` self-elevates.
- **S4.4** README / SAFETY / LOW-END-GUIDE.

## NFRs

| ID | Requirement | Threshold |
|----|-------------|-----------|
| N1 | Defender remains enabled | No script sets DisableAntiSpyware=1 or stops WinDefend |
| N2 | Windows Update remains functional | wuauserv/UsoSvc not disabled |
| N3 | Revert coverage | Every new script honors `$Revert` |
| N4 | Profile tests | `python3 tests/test_hardware_profile.py` exits 0 |
| N5 | HAGS | Off on Extreme/Low |
| N6 | SystemResponsiveness | 10, never 0 |

## MVP vs later

**MVP (this release):** profiles, AI, visuals, memory, startup, CLI/GUI, docs, tests.  
**Later:** live before/after RAM capture, HVCI benchmark helper, ARM64 investigation.

## Risk register

| Risk | L | I | Mitigation |
|------|---|---|------------|
| Policy names change in 26H2 | M | M | Prefer well-known policy values; Undo + restore point |
| CompactOS surprises users | L | M | Only when disk is tight |
| Startup restore incomplete | M | L | JSON backup + not touching SecurityHealth |
| Users disable HVCI expecting it in Turbo | L | L | Documented as manual |
