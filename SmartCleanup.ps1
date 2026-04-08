# 1. Set the safety threshold (7 days)
$Days = 7
$LastWrite = (Get-Date).AddDays(-$Days)

# 2. Define the target zones
$TargetFolders = @(
    "C:\Windows\Temp",      # System Temp
    "$env:TEMP",            # User Temp
    "C:\Windows\Prefetch"   # App Launch Cache
)

Write-Host "Starting Smart Purge (Files older than $Days days)..." -ForegroundColor Cyan

# 3. Process the folders
foreach ($Folder in $TargetFolders) {
    if (Test-Path $Folder) {
        Get-ChildItem -Path "$Folder\*" -Recurse -Force -ErrorAction SilentlyContinue | 
        Where-Object { $_.LastWriteTime -le $LastWrite } | 
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 4. Empty the Recycle Bin (All drives)
# Note: This clears the bin entirely regardless of file age
Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "Cleanup Complete! Your SSD thanks you." -ForegroundColor Green