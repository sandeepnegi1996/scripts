param(
    [switch]$DryRun,
    [switch]$NoLog
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptDir "update_log.txt"

function Write-LogEntry {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $msg = "[$ts] [$Level] $Message"
    if (-not $NoLog) {
        Add-Content -Path $LogFile -Value $msg -ErrorAction SilentlyContinue
    }
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "INFO"  { "Green" }
        default { "White" }
    }
    Write-Host $msg -ForegroundColor $color
}

try {
    Write-LogEntry "========== AutoUpdate.ps1 Started ==========" "INFO"
    Write-LogEntry "Dry-Run Mode: $DryRun" "INFO"

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-LogEntry "ERROR: winget not found" "ERROR"
        exit 2
    }
    Write-LogEntry "winget found" "INFO"

    Write-LogEntry "Detecting packages..." "INFO"
    Write-Progress -Activity "AutoUpdate" -Status "Scanning..." -PercentComplete -1

    $pkgList = @()
    try {
        $pkgList = @(& winget upgrade --all --include-unknown 2>&1 | Select-Object -Skip 3 | Where-Object {$_ -match '\S' -and $_ -notmatch '^-+$'})
    } catch {
        Write-LogEntry "Warning: Error querying packages" "WARN"
    }

    $total = $pkgList.Count
    
    if ($total -eq 0) {
        Write-LogEntry "No upgradeable packages found" "INFO"
        Write-Progress -Activity "AutoUpdate" -Completed
        exit 0
    }

    Write-LogEntry "Found $total package(s)" "INFO"
    
    $show = [Math]::Min($total, 5)
    for ($i = 0; $i -lt $show; $i++) {
        Write-LogEntry "  - $($pkgList[$i])" "INFO"
    }
    if ($total -gt 5) {
        Write-LogEntry "  ... and $($total - 5) more" "INFO"
    }

    if ($DryRun) {
        Write-LogEntry "DRY-RUN: Would upgrade $total packages" "INFO"
        Write-Progress -Activity "AutoUpdate" -Completed
        exit 0
    }

    Write-LogEntry "Starting upgrades..." "INFO"
    Write-Progress -Activity "AutoUpdate" -Status "Installing..." -PercentComplete 15

    $start = Get-Date
    $cmd = "winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --force --silent"
    Write-LogEntry "Running: $cmd" "INFO"
    
    $output = & cmd /c $cmd 2>&1
    $code = $LASTEXITCODE
    $dur = ((Get-Date) - $start).TotalSeconds

    if ($code -eq 0) {
        Write-Progress -Activity "AutoUpdate" -Status "Complete" -PercentComplete 100
        Write-LogEntry "Success (${dur}s)" "INFO"
        Write-Progress -Activity "AutoUpdate" -Completed
        exit 0
    } else {
        Write-LogEntry "Exit code: $code" "WARN"
        Write-Progress -Activity "AutoUpdate" -Completed
        exit $code
    }

} catch {
    Write-LogEntry "Exception: $($_.Exception.Message)" "ERROR"
    Write-Progress -Activity "AutoUpdate" -Completed
    exit 1
}