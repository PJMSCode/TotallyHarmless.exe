function Show-Process($Process, [Switch]$Maximize) {
    <#
      Function Courtesy of:
      community.idera.com/database-tools/powershell/powertips/b/
      tips/posts/bringing-window-in-the-foreground
    #>
    $sig = '
        [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
        [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);
    '
    if ($Maximize) { $Mode = 3 } else { $Mode = 4 }
    $type = Add-Type -MemberDefinition $sig -Name WindowAPI -PassThru
    $hwnd = $process.MainWindowHandle
    $null = $type::ShowWindowAsync($hwnd, $Mode)
    $null = $type::SetForegroundWindow($hwnd) 
}

Clear-Host
$wshell = New-Object -ComObject wscript.shell
$Null = $wshell.AppActivate('Chrome') # Activate the Opera browser

while ($true) {
    $action = Get-Random -Minimum 0 -Maximum 3 # Generates either 0, 1, 2
    if ($action -eq 0) {
        $wshell.SendKeys("^{t}") # CTRL + T to open a new tab
        $wshell.SendKeys("https://www.youtube.com/watch?v=IBkscgruZsM")  # Type the URL you want to navigate to
        $wshell.SendKeys("{ENTER}")  # Press Enter to navigate to the URL
        Start-Sleep -Seconds 6    # Wait for 6 seconds
    } elseif ($action -eq 1) {
        $wshell.SendKeys("^{t}") # CTRL + T to open a new tab
        $wshell.SendKeys("https://fakeupdate.net/win10ue/")  # Type the URL you want to navigate to
        $wshell.SendKeys("{ENTER}")  # Press Enter to navigate to the URL
        $wshell.SendKeys("{F11}") # Press F11 to go full screen
        Start-Sleep -Seconds 10800 # Wait for 3 hours
    } elseif ($action -eq 2){
        $wshell.SendKeys("^{t}") # CTRL + T to open a new tab
        $wshell.SendKeys("https://www.youtube.com/watch?v=4xnsmyI5KMQ")  # Type the URL you want to navigate to
        $wshell.SendKeys("{ENTER}")  # Press Enter to navigate to the URL
        Start-Sleep -Seconds 3600  # Wait for 6 seconds
    } else {
        $wshell.SendKeys("^{w}") # CTRL + W to close the current tab
    }

    Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 180) # Wait for a random interval (30-60 seconds)
}

Remove-Variable wshell
