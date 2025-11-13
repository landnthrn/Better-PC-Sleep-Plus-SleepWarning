<# 
Sleep Watcher - Idle Timer Adjustment
Interactive helper to update the idle timeout and restart the watcher task.
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$watcherScript = Join-Path $scriptDir "forcesleep.ps1"

if (-not (Test-Path $watcherScript)) {
    Write-Host "Unable to locate the sleep watcher script (forcesleep.ps1). Aborting." -ForegroundColor Red
    exit 1
}

$watcherContent = Get-Content -Path $watcherScript -Raw

if ($watcherContent -notmatch '\$ThresholdMinutes\s*=\s*(\d+)') {
    Write-Host "Could not read the current idle timer from the sleep watcher script. Aborting." -ForegroundColor Red
    exit 1
}

$currentMinutes = [int]$Matches[1]

function Format-IdleTime([int]$minutes) {
    if ($minutes -lt 60) {
        return "$minutes minute$(if ($minutes -eq 1) { '' } else { 's' })"
    }

    $hours = [math]::Floor($minutes / 60)
    $remainingMinutes = $minutes % 60

    if ($remainingMinutes -eq 0) {
        return "$hours hour$(if ($hours -eq 1) { '' } else { 's' })"
    }

    $parts = @()
    if ($hours -gt 0) {
        $parts += "$hours hour$(if ($hours -eq 1) { '' } else { 's' })"
    }
    if ($remainingMinutes -gt 0) {
        $parts += "$remainingMinutes minute$(if ($remainingMinutes -eq 1) { '' } else { 's' })"
    }

    return ($parts -join " ")
}

function Read-Int([string]$prompt, [int]$min, [int]$max) {
    while ($true) {
        $input = Read-Host "$prompt"
        $value = 0
        if ([int]::TryParse($input, [ref]$value) -and $value -ge $min -and $value -le $max) {
            return $value
        }
        Write-Host "Please enter a number between $min and $max." -ForegroundColor Yellow
    }
}

function Read-YesNo([string]$question) {
    while ($true) {
        if ($question) {
            Write-Host ""
            Write-Host $question
        }
        Write-Host ""
        $response = Read-Host "Enter y or n"
        switch ($response.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default {
                Write-Host ""
                Write-Host "Please enter 'y' or 'n'." -ForegroundColor Yellow
            }
        }
    }
}

Write-Host ""
Write-Host "Idle Timer Currently Set to: $(Format-IdleTime $currentMinutes)"
Write-Host ""
if (-not (Read-YesNo "Would you like to change the idle time?")) {
    exit 0
}
while ($true) {
    Write-Host ""
    Write-Host "(Enter 0 if you'd like)"
    $hours = Read-Int "Hours" 0 ([int]::MaxValue)
    Write-Host ""
    Write-Host "(Enter 0 if you'd like)"
    $minutes = Read-Int "Minutes" 0 59

    $newTotalMinutes = ($hours * 60) + $minutes

    if ($newTotalMinutes -le 0) {
        Write-Host ""
        Write-Host "Idle timer must be at least 1 minute. Please try again." -ForegroundColor Yellow
        continue
    }

    break
}

Write-Host ""
Write-Host "New Idle Timer Set to: $(Format-IdleTime $newTotalMinutes)"
Write-Host ""

if (-not (Read-YesNo "Ready to Apply?")) {
    Write-Host "No changes were made."
    exit 0
}

$regex = [regex]'(\$ThresholdMinutes\s*=\s*)(\d+)'
$updatedContent = $regex.Replace($watcherContent, { param($match) $match.Groups[1].Value + $newTotalMinutes }, 1)

try {
    Set-Content -Path $watcherScript -Value $updatedContent -Encoding UTF8
    Write-Host "Idle timer updated."
} catch {
    Write-Host "Failed to update the sleep watcher script: $_" -ForegroundColor Red
    exit 1
}

$restartCmd = 'schtasks /end /tn "ForceSleep_Watcher" & timeout /t 2 /nobreak >nul & schtasks /run /tn "ForceSleep_Watcher"'
Write-Host ""
Write-Host "Restarting sleep watcher task (ForceSleep_Watcher)..."
cmd.exe /c $restartCmd | Out-Null
$restartExit = $LASTEXITCODE

if ($restartExit -eq 0) {
    Write-Host "Sleep watcher task restarted with the new idle timer."
} else {
    Write-Host "The task restart command returned exit code $restartExit." -ForegroundColor Yellow
    Write-Host "Please verify the task state manually."
    exit $restartExit
}

exit 0

