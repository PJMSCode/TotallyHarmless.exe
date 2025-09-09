@echo off
:: Check if running as admin
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: Run PowerShell script with admin privileges
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\Persistence.ps1"
