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
$Null = $wshell.AppActivate('Opera') # Activate on Opera browser
Sleep 5 # Interval (in seconds) between switch 
$wshell.SendKeys("^{t}") # CTRL + T to open a new tab
Sleep 1 # Interval (in seconds) between switch 
$wshell.SendKeys("https://youtube.com")  # Type the URL you want to navigate to
Sleep 1 # Interval (in seconds) between switch 
$wshell.SendKeys("{ENTER}")  # Press Enter to navigate to the URL
Remove-Variable wshell
