# Changelog

## 2026.08 — Windows 11 Low-End Edition

Un-archived fork focused on Windows 11 22H2–25H2, including machines with 4–8 GB RAM.

### Added

- Hardware profiles: ExtremeLowEnd / LowEnd / MidRange / HighEnd (`Get-HardwareProfile.psm1`).
- Windows 11 AI pass: Copilot, Recall, Click to Do, Edge/Paint/Notepad AI, WSAIFabricSvc.
- Win11 shell pass: Widgets, Start Recommended, Gallery/Home, Snap suggestions, End Task.
- Low-end pass: visuals, SysMain/Search, pagefile, CompactOS, Storage Sense, startup cleanup.
- CLI presets: `CLI`, `LowEnd`, `Win11`, `Safe`.
- GUI: Optimize for Low-End PC, Disable Windows 11 AI, Show System Health, six new toggles.
- One-click launcher: `Win11-LowEnd.cmd`.
- Unit tests for profile thresholds (`tests/test_hardware_profile.py`).

### Changed

- Apply Tweaks now includes the Win11 + profile-aware low-end scripts.
- SystemResponsiveness is 10 (not 0) so the desktop does not starve on low-end CPUs.
- HAGS and Ultimate Performance are skipped on constrained hardware.
- Hibernate / Fast Startup follow laptop vs desktop and free disk.
- SysMain and Windows Search follow RAM + HDD, not "SSD ⇒ always on".
- Ndu is no longer forced Automatic (conflicts with the RAM-saving disable).
- FontCache stays Automatic (Manual first-paint lag on slow disks).
- Undo Tweaks reverts the new scripts and restores startup backups.

### Safety

- Defender, Windows Update, audio, Wi-Fi, firewall, and Print Spooler remain untouched.
- VBS / Memory Integrity is opt-in only.
- Restore point description updated for Windows 11.
