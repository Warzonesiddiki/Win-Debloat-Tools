@echo off
:: One-click Windows 11 low-end optimizer.
:: Creates a restore point, then applies the ExtremeLowEnd profile.
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator rights...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo  Win Debloat Tools  -  Windows 11 Low-End Turbo
echo  A restore point is created first. Reboot when it finishes.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0WinDebloatTools.ps1" LowEnd
echo.
echo Done. Reboot this PC once for every tweak to take effect.
pause
