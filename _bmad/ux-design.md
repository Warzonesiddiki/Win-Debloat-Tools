# UX — Low-end first

## Principle

The user who needs this most will not hunt through tabs. The primary action must be a single, brightly labelled button and a `.cmd` with the same name as the promise.

## Primary journeys

1. **Desperate 4 GB owner**  
   Download → Run `Win11-LowEnd.cmd` as admin → wait → reboot → desktop is quieter.

2. **Curious GUI user**  
   Open GUI → read title "Windows 11 Low-End" → **Optimize for Low-End PC** (green) or **Apply Tweaks** (cyan) → optional **Show System Health**.

3. **Enthusiast**  
   Uncheck/check Copilot, Recall, Widgets, Transparency, Animations, Fast Startup individually. Yellow **Undo Tweaks** if it went too far.

## Hierarchy (System Tweaks → Debloat column)

1. Apply Tweaks (profile-aware full path)
2. Optimize for Low-End PC (force Extreme)
3. Disable Windows 11 AI (narrow)
4. Undo Tweaks (yellow)
5. Existing cleanup / remove Edge / OneDrive / Xbox
6. Show System Health

## Copy

- Buttons say what happens to the PC, not the script name.
- Yellow = destructive or hard to undo (Edge, OneDrive, Xbox, Undo).
- Green = the low-end promise.

## Accessibility

Existing large hit targets and high-contrast dark theme stay. New checkboxes follow the same 40 px height.

## [ARCH FLAG]

GUI remains WinForms. No WinUI rewrite in this release.
