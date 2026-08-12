# Assumption Registry

| ID | Assumption | Risk | Validation | Status |
|----|------------|------|------------|--------|
| A1 | Idle Windows 11 24H2 on 8 GB often sits near 5–6 GB used | High | System Health + user reports | Open — literature consistent Aug 2026 |
| A2 | Copilot + Widgets + Recall are net-negative on ≤8 GB | High | Disable-WindowsAI then compare process set | Implemented; field measure pending |
| A3 | SysMain helps 16 GB+ SSD and hurts ≤8 GB / HDD | High | Profile split | Encoded in Resolve-HardwareProfile |
| A4 | Users will accept missing Widgets/Copilot if the desktop is snappy | Medium | Undo + toggles | Mitigated |
| A5 | Users will run a restore-point-first script as admin | Medium | Win11-LowEnd.cmd self-elevates | Mitigated |
| A6 | VBS/HVCI off is too dangerous to default | High | Left as manual checkbox | Accepted |
| A7 | ARM64 remains unsafe (historical #97) | High | Still blocked in README | Accepted |
| A8 | SystemResponsiveness=0 starves DWM on dual-core | Medium | Set to 10 | Implemented |
| A9 | CompactOS is worth the CPU tax under 20 GB free | Medium | Profile.UseCompactOS only | Implemented |
| A10 | SilentInstalledApps is how Copilot returns after Update | High | Policy lock in Disable-WindowsAI | Implemented |
| A11 | Print Spooler must stay on for Home users | Medium | Never in default disable list | Accepted |
| A12 | Memory Compression must stay on at 4 GB | High | KeepMemoryCompression=$true | Implemented |
