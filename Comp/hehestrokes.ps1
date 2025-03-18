# Load user32.dll functions for keyboard hooks
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class KeyboardHook
{
    private static IntPtr _hookID = IntPtr.Zero;
    private static LowLevelKeyboardProc _proc = HookCallback;
    private static bool suppressNext = false;

    public static void SetHook()
    {
        _hookID = SetWindowsHookEx(13, _proc, GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName), 0);
    }

    public static void Unhook()
    {
        UnhookWindowsHookEx(_hookID);
    }

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static void SimulateKeyPress(int vkCode, int times)
    {
        suppressNext = true; // Prevent infinite loop

        for (int i = 0; i < times; i++)
        {
            keybd_event((byte)vkCode, 0, 0, 0); // Key Down
            keybd_event((byte)vkCode, 0, 2, 0); // Key Up
        }

        suppressNext = false;
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0 && !suppressNext)
        {
            int vkCode = Marshal.ReadInt32(lParam);

            if (wParam == (IntPtr)0x100 || wParam == (IntPtr)0x104) // Key Down
            {
                if (vkCode == 8) // Backspace Key
                {
                    SimulateKeyPress(8, 3); // Triple Backspace
                }
                else
                {
                    SimulateKeyPress(vkCode, 2); // Double normal keys
                }
                return (IntPtr)1; // Suppress original key
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

    [DllImport("user32.dll")]
    private static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);
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