# --- CONFIG & LOGGING ---
$LogFile = "$env:USERPROFILE\Desktop\workspace_launch.log"
Start-Transcript -Path $LogFile -Append  # Records everything that happens


$Config = @{
    LogFile     = "$env:USERPROFILE\Desktop\workspace_launch.log"
    RepoPath    = "D:\priyusandy\sandy\code\agency-agents"
    WebProject  = "D:\priyusandy\sandy\code\scripts"
    ObsidianExe = "C:\Program Files\Obsidian\Obsidian.exe"
    NotepadExe  = "C:\Program Files (x86)\Notepad++\notepad++.exe"
    InsomniaExe = "$env:LOCALAPPDATA\insomnia\Insomnia.exe"
}

$Urls = @(
    "https://github.com",
    "https://gemini.google.com/",
    "https://chatgpt.com/",
    "https://sharepad.io/live/mqGcLs8/",
    "https://www.perplexity.ai/",
    "https://www.youtube.com/watch?v=KgH2FQwZXG0/"
)

# --- HELPER FUNCTIONS ---
function Start-SmartApp {
    param([string]$ExePath, [string]$ProcessName, [string]$Args = "")
    if (!(Get-Process $ProcessName -ErrorAction SilentlyContinue)) {
        Write-Host "-> Starting $ProcessName..." -ForegroundColor Cyan
        Start-Process $ExePath -ArgumentList $Args
        Start-Sleep -Seconds 7  # Give it a moment to launch
    } else {
        Write-Host "-> $ProcessName is already running." -ForegroundColor Gray
    }
}

try {
    Write-Host "--- WORKSPACE DEPLOYMENT STARTED at $(Get-Date) ---" -ForegroundColor Blue

    # 1. Connectivity Check
    if (Test-Connection 8.8.8.8 -Count 1 -Quiet) {
        Start-Process "chrome.exe" -ArgumentList $Urls
    }

    # 2. Git Sync (Production Standard: Update before you code)
    if (Test-Path $Config.RepoPath) {
        Push-Location $Config.RepoPath
        Write-Host "Updating local repository..."
        git fetch --quiet
        Pop-Location
    }



    # 3. Heavy Apps (Using Helper)
    Start-SmartApp -ExePath "idea64.exe" -ProcessName "idea64" -Args $Config.RepoPath
    Start-SmartApp -ExePath "code" -ProcessName "Code" -Args $Config.WebProject
    Start-SmartApp -ExePath $Config.ObsidianExe -ProcessName "Obsidian"
    Start-SmartApp -ExePath $Config.NotepadExe -ProcessName "notepad++"
    Start-SmartApp -ExePath $Config.InsomniaExe -ProcessName "Insomnia"




    Write-Host "-> Deploying Terminal Layout..." -ForegroundColor Cyan
# Opens WT: Top pane is your repo, bottom pane is your scripts
$WTArgs = "-d `"$($Config.RepoPath)`" ; split-pane -v -d `"$($Config.WebProject)`""
Start-Process "wt" -ArgumentList $WTArgs

    Write-Host "✅ Workspace Ready." -ForegroundColor Green
}
catch {
    Write-Error "Deployment Failed: $_"
}
finally {
    Stop-Transcript
}
