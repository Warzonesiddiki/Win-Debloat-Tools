# Sprint plan — Windows 11 Low-End Edition

**Goal:** Ship a reversible, hardware-aware Windows 11 toolkit that makes 4–8 GB PCs smooth.

| Order | Story | Status |
|------:|-------|--------|
| 1 | Hardware profile engine + tests | Done |
| 2 | Windows 11 AI + shell scripts | Done |
| 3 | Low-end visuals / memory / startup | Done |
| 4 | Wire CLI presets + GUI + cmd | Done |
| 5 | Teach existing scripts about profiles | Done |
| 6 | Docs, safety contract, BMAD v6 | Done |

Critical path: 1 → 2+3 → 4 → 5 → 6.

## Alignment check (PRD ↔ Architecture)

- Every epic maps to files under `src/` and `tests/`.
- NFR N1–N6 encoded in profile flags and protected-service comments.
- No HVCI default disable (ADR-3).
