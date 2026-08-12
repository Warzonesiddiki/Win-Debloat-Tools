# Product Brief — Win Debloat Tools, Windows 11 Low-End Edition

**Status:** Approved for implementation (Ultra-YOLO, confidence 88%)  
**Date:** 2026-08-12

## Vision

Windows 11 should feel like a minimal, responsive OS on the hardware people actually own — including 4 GB RAM and spinning disks — without turning their PC into an unpatchable science experiment.

## Users

1. **Primary — Low-spec owner.** 4–8 GB, HDD or 128 GB eMMC/SSD, Home edition. Wants one green button.
2. **Secondary — Enthusiast.** Wants Copilot/Recall/Widgets toggles and Undo.
3. **Tertiary — Refurb / lab tech.** Needs CLI presets and logs.

## Problems

- Stock 24H2/25H2 spends RAM on AI and news the user did not ask for.
- Classic debloat scripts are Win10-era or one-size-fits-all.
- Aggressive scripts disable Defender/Update and strand non-technical users.

## Constraints

- PowerShell 5.1, no extra runtime.
- x64 only (ARM still unsafe).
- Must create a restore point.
- Must keep Defender + Windows Update.

## Success

- After one reboot, a 4–8 GB PC has visible idle RAM headroom and a quieter disk.
- Copilot/Recall/Widgets policies are off and silent reinstall is blocked.
- Undo Tweaks or the restore point returns the machine to a usable stock-like state.
- High-end PCs are not stripped of transparency or Search.

## Out of scope

- Custom ISOs / NTLite.
- Disabling HVCI by default.
- Removing Edge WebView2.
- Supporting ARM64.
