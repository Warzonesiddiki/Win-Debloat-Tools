<!--
Self reminder: If the repository name changes, also update:
- src\lib\start-logging.psm1
- src\lib\title-templates.psm1 (LOGO)
- CONTRIBUTING.md
- README.md
- WinDebloatTools.ps1 (Window Title)
-->

# Win Debloat Tools — Windows 11 Low-End Edition

**Make Windows 11 feel like a clean, light OS — including 4 GB and 8 GB PCs.**

This is a maintained continuation of LeDragoX's Win-Debloat-Tools. The original project was archived after it grew past what one person could support. This edition keeps the proven GUI + revert model and rebuilds the default path around **Windows 11 22H2–25H2** and **extremely low-end hardware**.

> [!WARNING]
> **DISCLAIMER:** You run this at your own risk. A restore point is created first, and Undo Tweaks reverses what we can, but not every removed inbox app is trivial to put back. Read [docs/SAFETY.md](docs/SAFETY.md).

## Why this edition exists

Stock Windows 11 on a 4–8 GB machine often idles near the RAM ceiling before you open a browser. 24H2/25H2 added Copilot, Recall, Widgets (WebView2), Start recommendations, and silent Store reinstalls on top of the old telemetry and OEM junk.

This toolkit:

1. **Detects the PC** (RAM, cores, HDD vs SSD, free disk, laptop vs desktop).
2. **Applies the right amount of force** — ExtremeLowEnd is not HighEnd.
3. **Never disables Defender, Windows Update, audio, Wi-Fi, or printing.**
4. **Creates a restore point** and can undo the tweaks.

## Supported

| Item | Support |
|------|---------|
| OS | Windows 11 22H2, 23H2, 24H2, 25H2 (Windows 10 still runs the classic scripts) |
| Editions | Home / Pro |
| Arch | x64 (x86 works). **ARM/ARM64 will break the install** |
| PowerShell | Windows PowerShell 5.1+ |
| Hardware | Designed for 4 GB RAM / HDD up through high-end NVMe |

## Download and run

Use an **admin** account on a machine you can restore. Fresh installs show the biggest difference.

### Fastest path (low-end Windows 11)

1. Extract the **entire** zip.
2. Right-click [`Win11-LowEnd.cmd`](./Win11-LowEnd.cmd) → **Run as administrator**.
3. Reboot once when it finishes.

### GUI

```ps1
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File; .\"WinDebloatTools.ps1"
```

Or run `OpenTerminalHere.cmd` as admin and paste the line above.

The green **Optimize for Low-End PC** button is the one-click smoothness pass. **Apply Tweaks** is hardware-aware (less aggressive on 16 GB+).

![Script GUI](./src/assets/script-gui.png)

### CLI presets

```ps1
# Full recommended path (profile-aware, includes Win11 + low-end scripts)
.\WinDebloatTools.ps1 CLI

# Maximum smoothness (forces ExtremeLowEnd decisions)
.\WinDebloatTools.ps1 LowEnd

# Windows 11 AI + shell only (Copilot / Recall / Widgets / Start)
.\WinDebloatTools.ps1 Win11

# Conservative: bloat + privacy + Win11 AI, no service/feature surgery
.\WinDebloatTools.ps1 Safe
```

Individual scripts live in [`src/scripts`](./src/scripts).

## What you get on a 4–8 GB PC

| Area | What happens |
|------|----------------|
| AI (24H2/25H2) | Copilot, Recall, Click to Do, Edge/Paint/Notepad AI, WSAIFabricSvc off |
| Shell | Widgets, Chat, Search box, Start Recommended, Gallery, Snap suggestions gone |
| RAM | SysMain/Superfetch off when RAM is tight; background apps off; Edge boost off |
| Disk | Search indexer off on HDD/8 GB; Storage Sense on; CompactOS if the disk is tiny |
| GPU/DWM | Transparency and animations off; font smoothing + thumbnails kept |
| Boot | Startup OneDrive/Teams/Spotify/Discord/Steam helpers removed (backed up) |
| Power | High Performance on desktops; laptops keep their plan |
| Security | Defender, firewall, SmartScreen, UAC stay on |

Full list of "do not touch" components: [docs/SAFETY.md](docs/SAFETY.md).  
Walkthrough: [docs/LOW-END-GUIDE.md](docs/LOW-END-GUIDE.md).

## Roll-back

1. **Undo Tweaks** in the GUI (now includes Win11 AI, visuals, memory, and startup restore).
2. The restore point created at the start of the run.
3. **Repair Windows** if the image itself is damaged.

## Common script features

<details>
  <summary>Click to expand</summary>

Valid for **Apply Tweaks** and the `CLI` / `LowEnd` presets.

- Import modules, log to `%LOCALAPPDATA%\Temp\Win-DT-Logs`
- Restore point + hosts backup ([Backup-System.ps1](./src/scripts/Backup-System.ps1))
- AdwCleaner + O&O ShutUp10++ recommended profile ([Invoke-DebloatSoftware.ps1](./src/scripts/Invoke-DebloatSoftware.ps1))
- Telemetry scheduled tasks off ([Optimize-TaskScheduler.ps1](./src/scripts/Optimize-TaskScheduler.ps1))
- Hardware-aware services ([Optimize-ServicesRunning.ps1](./src/scripts/Optimize-ServicesRunning.ps1))
- Inbox + OEM + 24H2 bloat AppX removal ([Remove-BloatwareAppsList.ps1](./src/scripts/Remove-BloatwareAppsList.ps1))
- Privacy / GPO ([Optimize-Privacy.ps1](./src/scripts/Optimize-Privacy.ps1))
- Performance registries, HAGS only when safe ([Optimize-Performance.ps1](./src/scripts/Optimize-Performance.ps1))
- Explorer / taskbar personalization ([Register-PersonalTweaksList.ps1](./src/scripts/Register-PersonalTweaksList.ps1))
- Security hardening that does **not** disable Defender ([Optimize-Security.ps1](./src/scripts/Optimize-Security.ps1))
- Optional features + Recall ([Optimize-WindowsFeaturesList.ps1](./src/scripts/Optimize-WindowsFeaturesList.ps1))
- **New:** Windows 11 shell ([Optimize-Windows11.ps1](./src/scripts/Optimize-Windows11.ps1))
- **New:** Zero AI in Windows 11 ([Disable-WindowsAI.ps1](./src/scripts/Disable-WindowsAI.ps1))
- **New:** 100% Privacy & Telemetry Hardening ([Optimize-Privacy.ps1](./src/scripts/Optimize-Privacy.ps1))
- **New:** Network stack & latency tuning ([Optimize-Performance.ps1](./src/scripts/Optimize-Performance.ps1))
- **New:** Start Menu promotional mocked apps cleaner ([Register-PersonalTweaksList.ps1](./src/scripts/Register-PersonalTweaksList.ps1))
- **New:** Low-end smoothness ([Optimize-LowEndPC.ps1](./src/scripts/Optimize-LowEndPC.ps1))
- **New:** Startup cleanup ([Optimize-StartupApps.ps1](./src/scripts/Optimize-StartupApps.ps1))
- **New:** Visual effects ([Optimize-VisualEffects.ps1](./src/scripts/Optimize-VisualEffects.ps1))
- **New:** Memory / CompactOS / pagefile ([Optimize-Memory.ps1](./src/scripts/Optimize-Memory.ps1))
- **New:** Deep system cache & temporary files purge ([Remove-TemporaryFiles.ps1](./src/scripts/Remove-TemporaryFiles.ps1))

</details>

## GUI extras

<details>
  <summary>Click to expand</summary>

### Windows 11 toggles

- Enable/Disable **Copilot**, **Recall**, **Widgets**, **Transparency**, **Animations**, **Fast Startup**
- **Optimize for Low-End PC** — forces the ExtremeLowEnd profile
- **Disable Windows 11 AI** — Copilot / Recall / Click to Do / app AI only
- **Show System Health** — profile, RAM, disk, Copilot/Recall/Widgets, SysMain/Search

### Classic tools (unchanged)

Dark theme, clipboard, Cortana, hibernate, legacy context menu, location, News and Interests, Phone Link, Photo Viewer, telemetry, Spotlight, Xbox DVR, Edge/OneDrive/Xbox removal, software install via Winget/Chocolatey, Repair Windows, daily upgrade jobs.

</details>

## Hardware profiles

| Profile | Detected when | Aggressiveness |
|---------|----------------|----------------|
| ExtremeLowEnd | ≤4.5 GB RAM, or ≤6.5 GB + HDD | Maximum RAM/disk recovery |
| LowEnd | ≤8.5 GB, or any HDD, or ≤2 cores | SysMain/Search/visuals stripped |
| MidRange | ≤16.5 GB SSD | Transparency off, HAGS on |
| HighEnd | More than that | Stock glass, desktop Ultimate plan |

`Show System Health` prints the active profile. Override with `WIN_DEBLOAT_PROFILE_OVERRIDE=ExtremeLowEnd`.

## Contributing

Questions belong in Discussions. Bugs and features: open an Issue. Code: see [CONTRIBUTING.md](CONTRIBUTING.md).

Profile logic is covered by `python3 tests/test_hardware_profile.py`.

## Credits

- Original project: [LeDragoX/Win-Debloat-Tools](https://github.com/LeDragoX/Win-Debloat-Tools)
- Adapted from [W4RH4WK/Debloat-Windows-10](https://github.com/W4RH4WK/Debloat-Windows-10)
- LowSpecGamer, Fabio Akita, ChrisTitusTech, Adamx, Baboo, Daniel Persson, matthewjberger, and everyone who tested the original scripts
- Windows 11 24H2/25H2 policy map cross-checked against current public guidance (Copilot, Recall, Click to Do, Widgets)

## Roadmap

See [ROADMAP.md](ROADMAP.md) and [CHANGELOG.md](CHANGELOG.md).

## Alternatives

- [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) — broader interactive toolkit
- [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat) — lightweight Win11 declutter

This edition's differentiator is **hardware-aware low-end Windows 11**: the same GUI, but the default path is built for 4–8 GB machines and 24H2/25H2 AI surfaces.

## Legal

Not affiliated with Malwarebytes or O&O Software GmbH. AdwCleaner and ShutUp10++ have their own licenses.

Licensed under [MIT](LICENSE.txt).
