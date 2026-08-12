# Reasoning Ledger

| # | Date | Agent | Decision | DRP Summary | Confidence | Autonomy | Artifact |
|---|------|-------|----------|-------------|------------|----------|----------|
| 1 | 2026-08-12 | Rex | Revive archived toolkit for Win11 4–8 GB | Premise valid; stock 11 is heavy; competitors lack this GUI+profiles | 90% | A5 | research-report.md |
| 2 | 2026-08-12 | Blaze | Extend repo vs rewrite vs adopt Raphire | Steelman all three; rewrite too slow; Raphire lacks this UX | 88% | A5 | architecture.md ADR-1 |
| 3 | 2026-08-12 | Ana | Primary user is non-technical low-spec owner | One-click cmd + green button | 87% | A5 | product-brief.md |
| 4 | 2026-08-12 | Percy | Four CLI presets + profile-aware Apply Tweaks | Avoid a fifth "gaming" preset that disables HVCI | 86% | A5 | prd.md |
| 5 | 2026-08-12 | Archie | Pure Resolve-HardwareProfile + Python CI | Pester-only fails on Ubuntu runners | 92% | A5 | Get-HardwareProfile.psm1 |
| 6 | 2026-08-12 | Archie | Never default-disable HVCI/Defender/Update | Security is part of "runs perfectly" | 93% | A5 | docs/SAFETY.md |
| 7 | 2026-08-12 | Amelia | SystemResponsiveness=10 not 0 | 0 starves UI on dual-core | 89% | A5 | Optimize-Performance.ps1 |
| 8 | 2026-08-12 | Amelia | SysMain off when constrained even on SSD | 8 GB Superfetch fights the browser | 88% | A5 | Optimize-ServicesRunning.ps1 |
| 9 | 2026-08-12 | Quinn | 13/13 profile tests pass; protected list documented | Residual: field RAM numbers not measured in this sandbox | 86% | A4 | tests/test_hardware_profile.py |

## Ledger Entry #1 — 2026-08-12 — Rex

### Decision/Topic: Product direction = Windows 11 smoothness on extremely low-end PCs

### DRP Summary
| Stage | Analysis |
|-------|----------|
| First Principles | Users do not want "more toggles". They want Explorer and a browser to stay fluid on 4 GB. |
| Evidence | 24H2 AI surfaces; Microsoft 8 GB memory work; original script is Win10-era and archived. |
| Options | (1) Docs-only BMAD (2) New app (3) Upgrade this toolkit. Chose 3. |
| Risk | Folklore tweaks brick Update. Mitigation: safety contract. |
| Consequence | Fork becomes a living Win11 product. |
| Confidence | 90% |
| Autonomy | A5 |

### Adopted Path
Hardware-aware scripts + Win11 AI/shell + one-click LowEnd + Undo.

### Rejected Alternatives
Custom ISO factory (wrong user). Default HVCI off (security). Full rewrite (time).

### Open Items
Field before/after RAM on real 4 GB 24H2 hardware (cannot run here).

## Meta-cognition

Process: research → brief → implement in the existing style → tests for the only pure logic we can run on Linux. Improvement next time: a mocked CIM fixture so Get-HardwareProfile itself runs under pwsh on Ubuntu.
