# Sleep Watcher (forcesleep.ps1) - Idle Monitor
# Monitors keyboard/mouse idle time and applies the configured idle sleep timeout

$ThresholdMinutes = 25

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FlagFile = Join-Path $ScriptDir "FORCE_SLEEP_DISABLED.txt"

# Run silently - no output unless critical

# P/Invoke to detect true keyboard/mouse idle time
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class IdleHelper {
    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public static ulong GetIdleMilliseconds() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)System.Runtime.InteropServices.Marshal.SizeOf(lii);
        if (!GetLastInputInfo(ref lii)) return 0;
        return ((ulong)Environment.TickCount & 0xffffffff) - (ulong)lii.dwTime;
    }
}
'@ | Out-Null

$minIdleMs = [int64]($ThresholdMinutes * 60000)

# Track last sleep attempt time to prevent immediate re-sleep after wake
$lastSleepAttempt = $null
$wakeCooldownMinutes = 5  # Minimum minutes after wake before allowing sleep again
$lastIdleCheck = $null

# Function to kill any lingering sleep warning processes
function Kill-SleepWarningProcesses {
    try {
        # Kill by window title (most reliable method)
        Get-Process cmd -ErrorAction SilentlyContinue | Where-Object { 
            $_.MainWindowTitle -match "PC IS SLEEPY|SLEEP TIME" 
        } | Stop-Process -Force -ErrorAction SilentlyContinue
        
        # Also try to kill any cmd processes with the sleepwarning script path
        $countdownPath = Join-Path $ScriptDir "sleepwarning.cmd"
        Get-WmiObject Win32_Process -Filter "name='cmd.exe'" -ErrorAction SilentlyContinue | Where-Object {
            $_.CommandLine -like "*sleepwarning.cmd*"
        } | ForEach-Object {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
    } catch {
        # Ignore errors when killing processes
    }
}

while ($true) {
    try {
        # Check if disabled
        if (Test-Path $FlagFile) {
            Start-Sleep -Seconds 10
            continue
        }
        
        $idleMs = [IdleHelper]::GetIdleMilliseconds()
        
        # Detect wake scenario: if idle time suddenly drops significantly, we likely just woke up
        if ($lastIdleCheck -ne $null) {
            $idleDelta = $lastIdleCheck - $idleMs
            # If idle time dropped by more than 30 minutes, likely a wake scenario
            if ($idleDelta -gt (30 * 60 * 1000)) {
                # Kill any lingering sleep warning processes
                Kill-SleepWarningProcesses
                # Reset tracking - system likely just woke up
                $lastSleepAttempt = $null
                $lastIdleCheck = $idleMs
                Start-Sleep -Seconds 10
                continue
            }
        }
        
        # Detect suspiciously high idle time (likely indicates wake scenario)
        # If idle time is unreasonably high (> 24 hours), it's probably a wake scenario
        $maxReasonableIdleMs = 24 * 60 * 60 * 1000  # 24 hours in milliseconds
        if ($idleMs -gt $maxReasonableIdleMs) {
            # Kill any lingering sleep warning processes
            Kill-SleepWarningProcesses
            # Reset tracking - system likely just woke up
            $lastSleepAttempt = $null
            $lastIdleCheck = $idleMs
            Start-Sleep -Seconds 10
            continue
        }
        
        $lastIdleCheck = $idleMs
        
        # Check if we're within wake cooldown period
        if ($lastSleepAttempt -ne $null) {
            $timeSinceLastSleep = (Get-Date) - $lastSleepAttempt
            $cooldownMs = $wakeCooldownMinutes * 60 * 1000
            if ($timeSinceLastSleep.TotalMilliseconds -lt $cooldownMs) {
                # Still in cooldown period, skip sleep check
                Start-Sleep -Seconds 2
                continue
            }
        }
        
        if ($idleMs -ge $minIdleMs) {
            # Kill any existing sleep warning processes first (in case one is lingering)
            Kill-SleepWarningProcesses
            
            # Record sleep attempt time
            $lastSleepAttempt = Get-Date
            
            # Launch countdown window (CMD with ASCII art) - use start like test does
            $countdownPath = Join-Path $ScriptDir "sleepwarning.cmd"
            
            # Launch using start like the test does
            $proc = Start-Process cmd.exe -ArgumentList "/c", "start cmd /c `"$countdownPath`"" -WindowStyle Hidden -PassThru
            
            # Wait for process to exit, checking every 100ms
            while (-not $proc.HasExited) {
                Start-Sleep -Milliseconds 100
            }
            
            # Cool-down period after sleep attempt
            Start-Sleep -Seconds 60
        } else {
            Start-Sleep -Seconds 2
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Start-Sleep -Seconds 5
    }
}





















