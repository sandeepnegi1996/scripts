# --- CONFIG & LOGGING ---
$LogFile = "$env:USERPROFILE\Desktop\workspace_launch.log"
Start-Transcript -Path $LogFile -Append -ErrorAction SilentlyContinue

$RepoPaths = @(
    'D:\code'
)

$Urls = @(
    'https://github.com'
    'https://gemini.google.com/'
    'https://chatgpt.com/'
    'https://sharepad.io/live/mqGcLs8/'
    'https://www.perplexity.ai/'
    'https://www.youtube.com/watch?v=KgH2FQwZXG0/'
)

$Config = @{
    RepoPaths   = $RepoPaths
    LogFile     = $LogFile
    WebProject  = 'D:\code\scripts'
    Apps        = @{
        Obsidian  = 'C:\Program Files\Obsidian\Obsidian.exe'
        Notepad   = 'C:\Program Files\Notepad++\notepad++.exe'
    }
}

# --- UTILITY FUNCTIONS ---

function Test-ExecutableExists {
    param([string]$ExePath)
    if ([string]::IsNullOrWhiteSpace($ExePath)) { return $false }
    return (Test-Path $ExePath) -or (Get-Command $ExePath -ErrorAction SilentlyContinue)
}

function Test-ProcessRunning {
    param([string]$ProcessName)
    $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    return $null -ne $process
}

function Find-GitRepositories {
    param([string[]]$ParentPaths)
    $gitRepos = @()
    
    foreach ($parentPath in $ParentPaths) {
        if (-not (Test-Path $parentPath)) {
            Write-Host "⚠️  Parent path not found: $parentPath" -ForegroundColor Yellow
            continue
        }
        
        try {
            # Check if the parent path itself is a git repo
            if (Test-Path (Join-Path $parentPath '.git')) {
                $gitRepos += $parentPath
                Write-Host "  ✓ Found repo: $parentPath" -ForegroundColor Green
            }
            
            # Recursively find all .git directories in subdirectories (hidden, so use -Force)
            $gitDirs = Get-ChildItem -Path $parentPath -Filter ".git" -Recurse -Directory -Force -ErrorAction SilentlyContinue
            foreach ($gitDir in $gitDirs) {
                $repoPath = $gitDir.Parent.FullName
                $gitRepos += $repoPath
                Write-Host "  ✓ Found repo: $repoPath" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "✗ Error scanning $parentPath : $_" -ForegroundColor Red
        }
    }
    
    return $gitRepos | Select-Object -Unique
}

function Start-SmartApp {
    param(
        [string]$ExePath,
        [string]$ProcessName,
        [string]$Args = "",
        [int]$WaitSeconds = 5
    )
    
    # For common apps, try alternative locations if primary fails
    $finalExePath = $ExePath
    if (-not (Test-ExecutableExists $ExePath)) {
        # Try alternative locations for VS Code
        if ($ExePath -eq "code") {
            $alternatives = @(
                "$env:ProgramFiles\Microsoft VS Code\Code.exe",
                "$env:ProgramFiles\Microsoft VS Code Insiders\Code Insiders.exe",
                "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"
            )
            foreach ($alt in $alternatives) {
                if (Test-Path $alt) {
                    $finalExePath = $alt
                    break
                }
            }
        }
        
        if (-not (Test-ExecutableExists $finalExePath)) {
            Write-Host "✗ Executable not found: $ExePath" -ForegroundColor Red
            return
        }
    }
    
    # Check if already running
    if (Test-ProcessRunning $ProcessName) {
        Write-Host "→ $ProcessName already running" -ForegroundColor Gray
        return
    }
    
    try {
        Write-Host "→ Starting $ProcessName..." -ForegroundColor Cyan
        Start-Process $finalExePath -ArgumentList $Args -ErrorAction Stop
        Start-Sleep -Seconds $WaitSeconds
        Write-Host "✓ $ProcessName started" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to start $ProcessName : $_" -ForegroundColor Red
    }
}

function Update-GitRepositories {
    param([string[]]$RepoPaths)
    
    if ($RepoPaths.Count -eq 0) {
        Write-Host "⚠️  No git repositories found" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Updating $($RepoPaths.Count) git repository(ies)..." -ForegroundColor Cyan
    
    foreach ($repoPath in $RepoPaths) {
        try {
            Push-Location $repoPath
            Write-Host "  Updating: $repoPath" -ForegroundColor Cyan
            git fetch --quiet --all 2>$null
            Write-Host "  ✓ Updated" -ForegroundColor Green
            Pop-Location
        }
        catch {
            Write-Host "  ✗ Failed to update $repoPath : $_" -ForegroundColor Red
            Pop-Location
        }
    }
}

try {
    Write-Host "--- WORKSPACE DEPLOYMENT STARTED at $(Get-Date) ---" -ForegroundColor Blue

    # 1. CONNECTIVITY CHECK & BROWSER
    try {
        Write-Host "`n[1/5] Testing internet connectivity..." -ForegroundColor Blue
        if (Test-Connection 8.8.8.8 -Count 1 -Quiet) {
            Write-Host "✓ Internet online" -ForegroundColor Green
            Write-Host "→ Opening Chrome with URLs..." -ForegroundColor Cyan
            try {
                Start-Process "chrome.exe" -ArgumentList $Urls -ErrorAction Stop
                Write-Host "✓ Chrome opened" -ForegroundColor Green
            }
            catch {
                Write-Host "✗ Failed to open Chrome: $_" -ForegroundColor Red
                # Try Edge as fallback
                try {
                    Start-Process "msedge.exe" -ArgumentList $Urls
                    Write-Host "✓ Opened with Edge instead" -ForegroundColor Green
                }
                catch {
                    Write-Host "✗ No browser available" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "⚠️  No internet connection" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "✗ Connectivity check failed: $_" -ForegroundColor Red
    }

    # 2. GIT REPOSITORY SYNC
    try {
        Write-Host "`n[2/5] Syncing git repositories..." -ForegroundColor Blue
        $discoveredRepos = Find-GitRepositories -ParentPaths $Config.RepoPaths
        Update-GitRepositories -RepoPaths $discoveredRepos
    }
    catch {
        Write-Host "✗ Git sync failed: $_" -ForegroundColor Red
    }

    # 3. LAUNCH APPLICATIONS
    try {
        Write-Host "`n[3/5] Starting applications..." -ForegroundColor Blue
        
        # VS Code
        try {
            Start-SmartApp -ExePath "code" -ProcessName "Code" -Args $Config.WebProject -WaitSeconds 3
        }
        catch {
            Write-Host "✗ Failed to start VS Code: $_" -ForegroundColor Red
        }
        
        # Obsidian
        try {
            Start-SmartApp -ExePath $Config.Apps.Obsidian -ProcessName "Obsidian"
        }
        catch {
            Write-Host "✗ Failed to start Obsidian: $_" -ForegroundColor Red
        }
        
        # Notepad++
        try {
            Start-SmartApp -ExePath $Config.Apps.Notepad -ProcessName "notepad++"
        }
        catch {
            Write-Host "✗ Failed to start Notepad++: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ Application launch failed: $_" -ForegroundColor Red
    }

    # 4. TERMINAL LAYOUT
    try {
        Write-Host "`n[4/5] Deploying terminal layout..." -ForegroundColor Blue
        if (Test-Path $Config.WebProject) {
            $primaryRepo = if ($discoveredRepos.Count -gt 0) { $discoveredRepos[0] } else { $Config.WebProject }
            $WTArgs = "-d `"$primaryRepo`" ; split-pane -v -d `"$($Config.WebProject)`""
            Start-Process "wt" -ArgumentList $WTArgs -ErrorAction Stop
            Write-Host "✓ Terminal layout deployed" -ForegroundColor Green
        } else {
            Write-Host "⚠️  WebProject path not found: $($Config.WebProject)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "✗ Terminal deployment failed: $_" -ForegroundColor Red
    }

    Write-Host "`n✅ Workspace Ready." -ForegroundColor Green
}
catch {
    Write-Error "Deployment Failed: $_"
}
finally {
    Stop-Transcript
}
