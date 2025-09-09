@echo off
:: Batch script to execute the PowerShell Trolltab script

:: Hide the taskbar and start menu
Taskkill /IM explorer.exe /F

:: Run the PowerShell script
PowerShell -NoProfile -ExecutionPolicy Bypass -File "Trolltab.ps1"

:: Restore explorer when the script ends
Start explorer.exe
