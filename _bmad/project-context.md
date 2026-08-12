# Project Context — Win Debloat Tools (Windows 11 Low-End)

## Last Updated: 2026-08-12 | By: Amelia + Rex (BMAD v6)

## 1. Project Name & Description

Win Debloat Tools — a PowerShell 5.1 GUI/CLI that debloats and tunes Windows so **Windows 11 stays smooth on 4–8 GB PCs** without disabling Defender or Windows Update.

## 2. Current Phase & Status

**Phase 4 Delivery complete for the Low-End Edition MVP.** Ready for review/merge on `arena/019ff546-win-debloat-tools`.

## 3. Research Intelligence Summary

1. Stock 24H2/25H2 is RAM-heavy on 8 GB (Microsoft is still working on allocator/WinUI/WebView2).
2. Copilot, Recall, Widgets, Click to Do are the new tax versus the 2023 script.
3. SysMain helps rich SSDs and hurts 4–8 GB / HDD.
4. SystemResponsiveness=0 can starve DWM on dual-core.
5. HAGS is unsafe on old iGPUs.
6. SilentInstalledApps reinstalls Copilot.
7. HVCI costs FPS but is a security feature — opt-in only.
8. One-click `.cmd` beats a 40-toggle TUI for the primary user.
9. ARM64 remains unsafe.
10. Revert + restore point is the trust product.

## 4. Assumption Watchlist

See `_bmad/research/assumption-registry.md` (A1–A12).

## 5. Tech Stack

- Windows PowerShell 5.1, WinForms, registry, AppX, DISM, services, schtasks
- Python 3.11 for Linux CI profile tests
- GitHub Actions: PSScriptAnalyzer + `tests/test_hardware_profile.py`

## 6. Coding Standards

OTBS, 4-space, Verb-Noun, `Write-Status` / `Set-ItemPropertyVerified`, `$Revert -or $Global:Revert` on new scripts.

## 7. Architectural Patterns

- Hardware profile flags drive aggression
- Enable/disable pairs in `Windows11-Tweaks.psm1`
- Preset script lists in `Get-DebloatScriptList`
- Env override for Low-End Turbo
- Protected services never in default disable lists

## 8. Key Project-Specific Rules

- Do not disable WinDefend, wuauserv, Audiosrv, WlanSvc, Spooler, BFE
- Do not remove Store, Calculator, Photos, Camera, Snipping Tool, WebView2
- Do not default-disable HVCI
- Xbox/Edge/OneDrive stay optional yellow buttons

## 9. Environment & Tooling

Admin Windows 11 x64. Logs in `%LOCALAPPDATA%\Temp\Win-DT-Logs`. State in `%LOCALAPPDATA%\Win-Debloat-Tools\`.

## 10. YOLO Autonomy Tracker

Rex/Blaze/Ana/Percy/Uxie/Archie/Bob/Amelia/Quinn: A5 for this MVP. Guard (security): A4 — HVCI left manual.

## 11. Approved Artifacts Registry

research-report, assumption-registry, product-brief, prd, ux-design, architecture, sprint-plan, stories 1–6, this file, reasoning-ledger.

## 12. Brainstorm Sessions

Chose "extend this repo + hardware profiles" over rewrite or replacing the core with Win11Debloat.

## 13. Reasoning Ledger Reference

`_bmad/reasoning-ledger.md`

## 14. Glossary

- **ExtremeLowEnd:** ≤4.5 GB RAM or ≤6.5 GB + HDD
- **Low-End Turbo:** GUI/CLI path that forces ExtremeLowEnd
- **HAGS:** Hardware-Accelerated GPU Scheduling
- **HVCI:** Memory Integrity (VBS)

## 15. Change Log

2026-08-12 — Low-End Edition implemented end-to-end.
