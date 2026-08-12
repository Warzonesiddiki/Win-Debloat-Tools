# Windows 11 on a low-end PC

Goal: a 4–8 GB RAM, HDD or cheap SSD, dual/quad-core machine should boot, browse, and stay smooth.

## One-click

1. Extract the zip.
2. Right-click `Win11-LowEnd.cmd` → **Run as administrator**.
3. Wait for the restore point + scripts.
4. Reboot once.

Equivalent CLI:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\WinDebloatTools.ps1 LowEnd
```

## What "smooth" means here

On 4–8 GB Windows 11 24H2/25H2 the OS itself is the tax:

- Copilot, Recall, Widgets, and WebView2 news sit in RAM after login.
- SysMain / Superfetch races your browser for the same 4 GB.
- Search Indexer pins HDDs at 100%.
- Transparency, Snap flyouts, and animations cost GPU/DWM time on iGPU.
- Silent Store installs put Copilot back after Patch Tuesday.

Low-End Turbo turns those off, keeps Defender + Update, and sets visual effects for **performance while keeping font smoothing and thumbnails**.

## Profiles (automatic)

The toolkit measures RAM, CPU cores, C: media type, and free disk.

- **4 GB / 6 GB+HDD** → ExtremeLowEnd: CompactOS if the disk is tight, fixed pagefile, hibernate off on desktops, SysMain+Search off, no HAGS.
- **8 GB SSD** → LowEnd: same RAM-saving services and visuals, system-managed pagefile.
- **16 GB SSD** → MidRange: HAGS on, Search on, transparency still off.
- **32 GB+** → HighEnd: stock glass, Ultimate Performance offered on desktops.

## After the reboot

1. Open **Show System Health** in the GUI (or run `src\scripts\other-scripts\Show-SystemHealth.ps1`).
2. Idle RAM on an 8 GB box should drop well below the stock ~6 GB.
3. Disable leftover startups in Task Manager if a vendor helper survived.
4. If a game needs extra FPS and you accept the security trade, use the Memory Integrity checkbox yourself. It is **not** flipped automatically.

## Undo

GUI → **Undo Tweaks**, or keep the restore point from the start of the run.
