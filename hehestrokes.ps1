Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class KeyboardHook
{
    private static IntPtr _hookID = IntPtr.Zero;
    private static LowLevelKeyboardProc _proc = HookCallback;

    public static void SetHook()
    {
        _hookID = SetWindowsHookEx(13, _proc, GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName), 0);
    }

    public static void Unhook()
    {
        UnhookWindowsHookEx(_hookID);
    }

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0)
        {
            int vkCode = Marshal.ReadInt32(lParam);
            string key = ((Keys)vkCode).ToString();

            if (wParam == (IntPtr)0x100 || wParam == (IntPtr)0x104) // Key Down
            {
                if (key == "Back")
                {
                    SendKeys.SendWait("{BACKSPACE}{BACKSPACE}{BACKSPACE}");
                    return (IntPtr)1; // Suppress original key
                }
                else
                {
                    SendKeys.SendWait(key + key);
                    return (IntPtr)1; // Suppress original key
                }
            }
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll")]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);
}
"@ -Language CSharp

# Set the keyboard hook
[KeyboardHook]::SetHook()

Write-Host "Keyboard Hook Active. Press CTRL+C to exit."

# Keep the script running
try {
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    [KeyboardHook]::Unhook()
    Write-Host "Keyboard Hook Removed."
}