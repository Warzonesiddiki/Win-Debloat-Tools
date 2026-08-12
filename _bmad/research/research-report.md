# Research Report — Windows 11 Low-End Smoothness

**Date:** 2026-08-12  
**Agent:** Rex (BMAD v6)  
**Verdict:** Proceed. The original toolkit is a strong chassis; it is missing 24H2/25H2 AI surfaces and hardware-aware aggression.

## 1. Problem space

Windows 11 officially supports 4 GB RAM. In 2026 that configuration is common on office refurb laptops and Celeron/N-series boxes. Microsoft has publicly said memory optimization for 8 GB PCs is a 2026 focus — which is an admission that stock 11 is heavy.

Symptoms users actually feel:

- 30–90 s to a usable desktop after login
- Explorer/DWM hitching when opening the Start menu
- HDD 100% from Search + SysMain
- Browser OOM after a handful of tabs
- Copilot / Widgets WebView2 processes after a feature update

## 2. Market and opportunity

Crowded category: winutil, Win11Debloat (Raphire), OOShutUp, random .bat files. Gap: **one GUI that already exists**, plus **automatic ExtremeLowEnd vs HighEnd**, plus **revert**, plus **do not brick Update/Defender**.

## 3. User and behavior

Primary user: non-technical owner of a 4–8 GB Windows 11 Home PC. They will double-click a `.cmd` if it is obviously named. They will not read a 40-toggle TUI first.

Secondary: enthusiast who wants per-toggle Copilot/Recall/Widgets.

## 4. Competitive landscape

| Tool | Strength | Gap we fill |
|------|----------|-------------|
| Raphire Win11Debloat | Current AI/reg map | No hardware profiles, less "make 4 GB usable" |
| Chris Titus winutil | Huge surface | Heavier, not low-end-first |
| Original Win-Debloat-Tools | GUI, revert, libs | Archived; Win10-era; SysMain-on-SSD always |

## 5. Technical feasibility

All changes are PowerShell 5.1 + documented HKLM/HKCU policies + AppX + services + DISM. No kernel drivers. Restore point + `$Revert` already exist.

## 6. Strategic risk

- Over-debloat that breaks Store apps depending on WebView2 (we do not remove WebView2).
- Disabling HVCI by default (we do not).
- Copilot reinstall via SilentInstalledApps (we lock it).
- CompactOS on a fast NVMe with 200 GB free (profile prevents it).

## Disconfirmation search

Sought evidence that "just leave Windows 11 stock" is fine on 4 GB. Microsoft's own 8 GB memory work and widespread idle-RAM reports contradict that. Sought evidence SysMain should stay on at 8 GB SSD — mixed; we disable only when constrained.

## Research Risk Score

**Medium.** Policies move between builds; we prefer Group Policy registry names that have survived 23H2→25H2 (TurnOffWindowsCopilot, AllowRecallEnablement, AllowNewsAndInterests).
