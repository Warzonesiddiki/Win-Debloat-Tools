# Changelog

## 2026.08 — Windows 11 Low-End Edition (Zero-AI & 100% Privacy Update)

Un-archived fork focused on Windows 11 22H2–25H2, including machines with 4–8 GB RAM.

### Added

- Hardware profiles: ExtremeLowEnd / LowEnd / MidRange / HighEnd (`Get-HardwareProfile.psm1`).
- **Zero AI in Windows 11**: Complete removal & policy locks for Microsoft Copilot, Windows Recall, Click to Do, built-in App AI (Edge, Paint, Notepad, Photos Generative Erase), Windows Studio Effects, AI Semantic Search, Phi Silica / Model Downloads, and `WSAIFabricSvc`.
- **100% Privacy Hardening**: Strict telemetry level 0 lock, Device Census disabled, Windows Error Reporting telemetry off, Bing search in Start & Cloud Search disabled, search box suggestions off, Content Delivery Manager ad feeds blocked, Inking/Typing surveillance disabled, AutoLogger diagnostic traces off, and CEIP disabled.
- **Advanced Network & Performance Tuning**: TCP Window Auto-Tuning, CUBIC/CTCP congestion provider, Receive Side Scaling (RSS) enabled, TCP Chimney offload disabled, NTFS last-access timestamp chatter disabled, and Explorer startup latency eliminated.
- Win11 shell pass: Widgets, Start Recommended, Gallery/Home, Snap suggestions, End Task.
- Low-end pass: visuals, SysMain/Search, pagefile, CompactOS, Storage Sense, startup cleanup.
- CLI presets: `CLI`, `LowEnd`, `Win11`, `Safe`.
- GUI: Optimize for Low-End PC, Disable Windows 11 AI, Show System Health, modern package options (Ente Auth, VMware Pro, Java 21 LTS).
- One-click launcher: `Win11-LowEnd.cmd`.
- Comprehensive automated test suite (`tests/test_hardware_profile.py` & `tests/test_workspace_integrity.py`).

### Changed

- Replaced unsafe `Invoke-Expression` string evaluation in registry helpers with native PowerShell parameter splatting (`@params`).
- Replaced deprecated `wmic.exe` commands with native CIM and registry configurations (full 24H2/25H2 compatibility).
- Resolved missing module imports across all standalone scripts for 100% CLI and sub-process reliability.
- Updated software installer catalog: replaced EOL Twilio Authy with Ente Auth, updated VMware Workstation Pro, and modernized Java JDK to LTS 8/17/21.
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
