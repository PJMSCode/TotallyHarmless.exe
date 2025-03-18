function Show-Process($Process, [Switch]$Maximize) {

    <#
      Function Courtsy of:
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
    Set-Clipboard -Value $null
    $wshell=New-Object -ComObject wscript.shell
    $Null = $wshell.AppActivate('Opera') # Activate on Chrome browser
    Sleep 5 # Interval (in seconds) between switch 
    $wshell.SendKeys("^{e}") # CTRL + E
    Sleep 1 # Interval (in seconds) between switch 
    $wshell.SendKeys("^{c}")  # CTRL + C
    Sleep 1 # Interval (in seconds) between switch 
    $MyURL = Get-Clipboard
    "$MyURL"
    $PSId = (Get-process -name "PowerShell*").ID
    Show-Process -Process (Get-Process -Id $PSId) -Maximize
    Remove-Variable wshell