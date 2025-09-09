#!/bin/bash
# Stealthy Privilege Escalation Scanner - Linux
# Author: Promise James

# Avoid writing to disk. Only stdout.
echo "[*] Checking for sudo privileges..."
sudo -l 2>/dev/null

echo "[*] Scanning for SUID binaries..."
find / -perm -4000 -type f 2>/dev/null

echo "[*] Searching for world-writable files in PATH..."
IFS=':' read -ra DIRS <<< "$PATH"
for dir in "${DIRS[@]}"; do
    find "$dir" -type f -perm -0002 -exec ls -la {} \; 2>/dev/null
done

echo "[*] Looking for potential cron jobs..."
ls -al /etc/cron* 2>/dev/null
cat /etc/crontab 2>/dev/null

echo "[*] Checking .bash_history and recent commands..."
cat ~/.bash_history 2>/dev/null
history | tail -n 20

echo "[*] Checking for writable config files..."
find /etc -type f -writable 2>/dev/null | grep -Ev '\/proc|\/sys'

echo "[*] Inspecting running processes (looking for suspicious root-owned ones)..."
ps aux | grep root

echo "[*] Done."
