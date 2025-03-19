# Standalone Trolltab Script with YouTube Kiosk Mode, Developer Escape, and HTML-based Duration Retrieval
# -----------------------------------------------------------------------------------------------
# This script:
# 1. Plays a designated special video once (it will not be repeated).
# 2. Enters an infinite loop to randomly select and play one of several YouTube videos.
#
# For each video:
# - The script retrieves the video's duration by downloading its YouTube page and parsing the HTML.
# - It maximizes system volume by simulating "Volume Up" key presses.
# - It disables both keyboard and mouse input (via BlockInput) so that user input is ignored.
# - It launches Microsoft Edge in kiosk mode (using the --kiosk parameter) so that YouTube displays in full-screen.
# - It waits for the video's exact duration before re-enabling input.
# - It then waits a random interval (5-10 minutes) before playing the next video.
#
# A developer escape function is provided: if the file "C:\dev_escape.txt" exists,
# the script will immediately re-enable input and terminate (the file is not deleted).
#
# Note: For reliable BlockInput, run this script as an administrator.

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
$escapeTimer = New-Object System.Timers.Timer
$escapeTimer.Interval = 1000
$escapeTimer.AutoReset = $true
$escapeTimer.Enabled = $true
$escapeTimer.Add_Elapsed({
    if (Test-Path "D:\dev_escape.txt") {
        # Re-enable keyboard and mouse input
        [KeyboardDisabler]::BlockInput($false)
        Write-Host "Developer escape triggered. Exiting script..."
        Stop-Process -Id $PID
    }
})

# --- Function to Retrieve Video Duration from YouTube Page ---
function Get-VideoDuration {
    param(
        [string]$url
    )
    try {
        # Set a common User-Agent header to mimic a browser
        $headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        }
        $response = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing -ErrorAction Stop
        if ($response -and $response.Content) {
            # Look for "lengthSeconds":"<number>" in the HTML
            $regex = '"lengthSeconds":"(\d+)"'
            $match = [regex]::Match($response.Content, $regex)
            if ($match.Success) {
                $seconds = [int]$match.Groups[1].Value
                return $seconds
            }
            else {
                Write-Host "Duration not found in HTML for $url. Using default duration of 180 seconds."
                return 180
            }
        }
        else {
            Write-Host "Failed to get HTML content for $url. Using default duration of 180 seconds."
            return 180
        }
    }
    catch {
        Write-Host "Error retrieving duration for $url"
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
    
    # Maximize system volume by sending "Volume Up" keys
    $WshShell = New-Object -ComObject WScript.Shell
    for ($i = 0; $i -lt 50; $i++) {
        $WshShell.SendKeys([char]175)
        Start-Sleep -Milliseconds 100
    }
    
    # Disable keyboard and mouse input
    [KeyboardDisabler]::BlockInput($true)
    
    # Launch Microsoft Edge in kiosk mode (true full-screen for YouTube)
    Start-Process "msedge.exe" "--kiosk $url"
    
    # Wait for the video's duration
    Start-Sleep -Seconds $duration
    
    # Re-enable input
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
