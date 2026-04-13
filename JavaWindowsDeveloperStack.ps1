# ==========================================
# 🚀 FIXED JAVA DEV ENV SETUP (WINGET ONLY)
# ==========================================

Write-Host "🚀 Starting Unattended Java Dev Setup..." -ForegroundColor Cyan
$ErrorActionPreference = "Continue"
$ProgressPreference = 'SilentlyContinue'

# -------------------------------
# REPORT TRACKING
# -------------------------------
$SuccessList = @()
$FailedList = @()

# -------------------------------
# Ensure Winget Exists
# -------------------------------
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Winget not found. Install App Installer." -ForegroundColor Red
    exit 1
}

# -------------------------------
# INSTALL FUNCTION (NO PROMPTS)
# -------------------------------
function Install-Package {
    param ([string]$wingetId)

    Write-Host "`n➡️ Processing: $wingetId" -ForegroundColor Yellow

    try {
        $installed = winget list --id $wingetId -e 2>$null

        if ($installed) {
            Write-Host "  Already installed, checking for upgrades..." -ForegroundColor Gray
            winget upgrade --id $wingetId --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
            $SuccessList += $wingetId
            return
        }

        winget install --id $wingetId --silent --accept-package-agreements --accept-source-agreements --disable-interactivity

        if ($LASTEXITCODE -eq 0) {
            $SuccessList += $wingetId
        } else {
            throw "Install failed with exit code $LASTEXITCODE"
        }

    } catch {
        Write-Host "❌ Failed: $wingetId" -ForegroundColor Red
        $FailedList += $wingetId
    }
}

# -------------------------------
# PACKAGE LIST
# -------------------------------
$packages = @(
    "EclipseAdoptium.Temurin.21.JDK",
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "JetBrains.IntelliJIDEA.Community",
    "Docker.DockerDesktop",
    "Postman.Postman",
    "DBeaver.DBeaver",
    "Python.Python.3",
    "OpenJS.NodeJS.LTS",
    "Microsoft.WindowsTerminal",
    "JanDeDobbeleer.OhMyPosh",
    "Notepad++.Notepad++",
    "7zip.7zip",
    "ShareX.ShareX",
    "Kubernetes.kubectl",
    "Helm.Helm",
    "Hashicorp.Terraform",
    "Hashicorp.Packer",
    "Hashicorp.Vagrant"
)

# -------------------------------
# INSTALL ALL PACKAGES
# -------------------------------
foreach ($pkg in $packages) {
    Install-Package -wingetId $pkg
}

# -------------------------------
# REFRESH ENVIRONMENT PATH
# -------------------------------
# This is crucial so the script finds 'code' and 'git' after they are installed
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# -------------------------------
# Set JAVA_HOME
# -------------------------------
Write-Host "`n⚙️ Setting JAVA_HOME..." -ForegroundColor Cyan
try {
    $javaPath = (Get-ChildItem "C:\Program Files\Eclipse Adoptium" -Directory |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1).FullName

    if ($javaPath) {
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "Machine")
        Write-Host "  ✅ JAVA_HOME set to: $javaPath" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️ Could not set JAVA_HOME automatically." -ForegroundColor DarkYellow
}

# -------------------------------
# VS CODE EXTENSIONS (Silent & Efficient)
# -------------------------------
Write-Host "`n🧩 Installing VS Code Extensions..." -ForegroundColor Cyan

# Find the VS Code executable path directly to avoid shell issues
$vscodePath = Get-Command code -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (!$vscodePath) {
    $vscodePath = "$env:LocalAppData\Programs\Microsoft VS Code\bin\code.cmd"
}

if (Test-Path $vscodePath) {
    $vsExtensions = @(
        "vscjava.vscode-java-pack", "redhat.java", "vscjava.vscode-java-debug",
        "vscjava.vscode-java-test", "vscjava.vscode-maven", "vmware.vscode-spring-boot",
        "vmware.vscode-spring-initializr", "vmware.vscode-spring-boot-dashboard",
        "hbenl.vscode-test-explorer", "alefragnani.project-manager", "eamodio.gitlens",
        "humao.rest-client", "yzhang.markdown-all-in-one", "shd101wyy.markdown-preview-enhanced",
        "ms-azuretools.vscode-docker", "ms-kubernetes-tools.vscode-kubernetes-tools",
        "esbenp.prettier-vscode", "editorconfig.editorconfig", "usernamehw.errorlens"
    )

    # Convert the array into a single command: code --install-extension ext1 --install-extension ext2
    # This prevents spawning multiple windows!
    $extArgs = $vsExtensions | ForEach-Object { "--install-extension $_" }
    $extArgs += "--force"

    Write-Host "  Processing all extensions in one batch... please wait." -ForegroundColor Gray
    Start-Process -FilePath $vscodePath -ArgumentList $extArgs -Wait -NoNewWindow
    Write-Host "  ✅ Extensions installed." -ForegroundColor Green
} else {
    Write-Host "  ❌ VS Code executable not found. Skipping extensions." -ForegroundColor Red
}

# -------------------------------
# Oh My Posh & Git Config
# -------------------------------
Write-Host "`n🎨 Finalizing Configs..." -ForegroundColor Cyan

if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
$ompConfig = 'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression'
if (!(Select-String -Path $PROFILE -Pattern "oh-my-posh" -Quiet)) {
    Add-Content -Path $PROFILE -Value $ompConfig
}

git config --global core.autocrlf true
git config --global init.defaultBranch main

# -------------------------------
# FINAL REPORT
# -------------------------------
Write-Host "`n==============================="
Write-Host "📊 INSTALLATION REPORT"
Write-Host "==============================="

Write-Host "✅ SUCCESSFUL:" -ForegroundColor Green
$SuccessList | Sort-Object | Get-Unique | ForEach-Object { Write-Host "  ✔ $_" }

if ($FailedList.Count -gt 0) {
    Write-Host "`n❌ FAILED:" -ForegroundColor Red
    $FailedList | Sort-Object | Get-Unique | ForEach-Object { Write-Host "  ✖ $_" }
} else {
    Write-Host "`n🎉 All tasks completed successfully!" -ForegroundColor Cyan
}