# Safety contract

Win Debloat Tools is built so a 4 GB Windows 11 PC can feel usable **without** breaking the OS.

## Never disabled by default

| Component | Why it stays |
|-----------|----------------|
| Microsoft Defender / Security Center | Real-time protection. Sandbox mode stays off (RAM). |
| Windows Update (`wuauserv`, `UsoSvc`) | Security patches. Auto-reboot while signed in is blocked. |
| Networking stack (DHCP, DNS, NLA, BFE, firewall) | Offline PCs are not "optimized". |
| Audio (`Audiosrv`) | Users still need sound. |
| Print Spooler | Printing stays available. Dedicated toggle only. |
| Wi-Fi (`WlanSvc`) | Laptops must stay online. |
| Windows Store, Calculator, Photos, Camera, Snipping Tool, Notepad, Paint | Daily-driver apps. |
| Memory Compression | Essential on 4–8 GB RAM. |

## Optional and labelled

- Removing Edge, OneDrive, or Xbox is a **separate yellow button**, never part of Apply Tweaks.
- Memory Integrity / VBS is a **manual checkbox**. It is not flipped by Low-End Turbo (security vs FPS is the user's call).
- Hyper-V / Sandbox / WSL stay off the default path.

## Reversibility

1. A System Restore Point is created first (`Backup-System.ps1`).
2. Hosts file is copied to `hosts_Backup`.
3. Startup apps we remove are saved under `%LOCALAPPDATA%\Win-Debloat-Tools\startup-backup.json`.
4. **Undo Tweaks** walks every new Windows 11 / low-end script with `-Revert`.

## Hardware-aware aggression

| Profile | Typical box | What we refuse to do |
|---------|-------------|----------------------|
| ExtremeLowEnd | ≤4 GB or 6 GB+HDD | No HAGS, no Ultimate Performance, no hibernate file on desktops |
| LowEnd | ≤8 GB or any HDD | SysMain/Search off, visuals stripped, AI off |
| MidRange | ≤16 GB SSD | Light visuals, HAGS on, Search on |
| HighEnd | 16 GB+ SSD | Stock appearance, Ultimate plan on desktops only |

Override: `WIN_DEBLOAT_PROFILE_OVERRIDE=ExtremeLowEnd` or the **Optimize for Low-End PC** button.

## ARM64

ARM/ARM64 is still unsupported. Do not run this toolkit on Snapdragon Windows images.
