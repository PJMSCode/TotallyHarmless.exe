# Persistent Script Execution
# This script ensures that all scripts in a folder run persistently, even after a restart

# Set script execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Get the script directory
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Create a Scheduled Task to run all scripts at startup
$TaskName = "PersistentScripts"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath\startup.ps1`""
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable

# Register the task
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $TaskSettings -Force

# Create a startup script to execute all scripts in the folder
$StartupScript = "$ScriptPath\startup.ps1"

$StartupContent = @"
`$Scripts = Get-ChildItem -Path "$ScriptPath" -Filter "*.ps1"
foreach (`$Script in `$Scripts) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"`$($Script.FullName)`"" -Verb RunAs
}
"@

# Write the startup script
$StartupContent | Set-Content -Path $StartupScript -Force

Write-Host "All scripts in $ScriptPath will now run persistently after a restart."
