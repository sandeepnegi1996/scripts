# --- CONFIGURATION ---
$LogFile = "$env:USERPROFILE\Desktop\workspace_shutdown.log"
Start-Transcript -Path $LogFile -Append  # Records everything that happens

$RepoPath = "D:\priyusandy\sandy\code\agency-agents"
$TimeoutSeconds = 10

$Config = @{
    LogFile     = "$env:USERPROFILE\Desktop\workspace_shutdown.log"
    RepoPath    = "D:\priyusandy\sandy\code\agency-agents"
    NotesPath   = "D:\priyusandy\sandy\code\ObsidianNotes" # <--- Obsidian vault path for syncing
    AppsToClose = @("idea64", "Code", "Insomnia", "Obsidian", "notepad++")
    Timeout     = 10
}


function Close-AppGracefully {
    param([string]$ProcessName)

    $Proc = Get-Process $ProcessName -ErrorAction SilentlyContinue
    if ($Proc) {
        Write-Host "-> Requesting $ProcessName to save and close..." -ForegroundColor Cyan
        
        # This sends the 'X' button signal to the app
        $Proc.CloseMainWindow() | Out-Null

        # Wait to see if it closes on its own
        $Timer = 0
        while (!( $Proc.HasExited ) -and $Timer -lt $TimeoutSeconds) {
            Start-Sleep -Seconds 1
            $Timer++
        }

        if ($Proc.HasExited) {
            Write-Host "✅ $ProcessName closed safely." -ForegroundColor Green
        } else {
            Write-Host "⚠️ $ProcessName is still running (might be waiting for a 'Save' click)." -ForegroundColor Yellow
            # We do NOT force kill here because we want to preserve data.
        }
    }
}

function Sync-GitRepo {
    param([string]$Path, [string]$Label)
    if (Test-Path $Path) {
        Write-Host "--- Checking $Label for changes ---" -ForegroundColor Blue
        Push-Location $Path
        
        # Check if there are any changes (added, modified, or deleted)
        if (git status --porcelain) {
            Write-Host "📦 Found changes in $Label. Syncing..." -ForegroundColor Yellow
            git add .
            git commit -m "Auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            
            Write-Host "🚀 Pushing to remote..." -ForegroundColor Gray
            $PushResult = git push 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $Label synced successfully." -ForegroundColor Green
            } else {
                Write-Error "❌ Push failed for $Label. Check for merge conflicts!`n$PushResult"
            }
        } else {
            Write-Host "✅ $Label is already up to date." -ForegroundColor Gray
        }
        Pop-Location
    }
}

try {
    Write-Host "--- 🌙 INITIATING SAFE SHUTDOWN ---" -ForegroundColor Blue

    # 2. Close Apps One-by-One
    foreach ($App in $Config.AppsToClose) {
        Close-AppGracefully -ProcessName $App
    }

    # 2. Give the system a second to release file locks
    Start-Sleep -Seconds 3

    # 4. Sync Obsidian Vault
    Sync-GitRepo -Path $Config.NotesPath -Label "Obsidian Notes"

    # 3. Chrome Check (Optional)
    # Chrome handles its own 'Restore Session', but we can close it too.
    Close-AppGracefully -ProcessName "chrome"

    Write-Host "✨ Safe Shutdown sequence complete." -ForegroundColor Green
}
catch {
    Write-Error "Shutdown script encountered an error: $_"
}