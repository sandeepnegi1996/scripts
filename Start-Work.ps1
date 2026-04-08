
# --- CONFIG & LOGGING ---
$LogFile = "$env:USERPROFILE\Desktop\workspace_launch.log"
Start-Transcript -Path $LogFile -Append  # Records everything that happens


# --- CONFIGURATION ---
# Define paths to your projects
$WebProject = "D:\priyusandy\sandy\code\scripts"
# $BackendProject = "C:\Users\YourName\Repos\java-service"
# $NotesVault = "MyDevVault" # Name of your Obsidian Vault

$Urls = @(
    "https://github.com",
    "https://gemini.google.com/",
    "https://chatgpt.com/",
    "https://sharepad.io/live/mqGcLs8/",
    "https://www.perplexity.ai/",
    "https://www.youtube.com/watch?v=KgH2FQwZXG0/"
)

# --- THE LAUNCHER ---
Write-Host "☕ Brewing your workspace..." -ForegroundColor Yellow


Write-Host "🔍 Running Pre-Flight Checks..." -ForegroundColor Cyan

if (!(Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet)) {
    Write-Error "No internet connection detected. Aborting web-related launches."
    $LaunchWeb = $false
} else {
    $LaunchWeb = $true
}


# 1. Obsidian (Specific Vault via URI)
Write-Host "-> Opening Brain (Obsidian)"
Start-Process "C:\Program Files\Obsidian\Obsidian.exe"
Start-Sleep -Seconds 2



# 2. VS Code (Specific Project)
Write-Host "-> Opening Project (VS Code)"
if (Get-Command "code" -ErrorAction SilentlyContinue) {
    Start-Process "code" -ArgumentList $WebProject
}
Start-Sleep -Seconds 2


# 4. API Testing & Documentation
Write-Host "-> Opening Insomnia & OneNote"
Start-Process "C:\Users\priyu\AppData\Local\insomnia\Insomnia.exe"
Start-Sleep -Seconds 2

# --- 6. Google Chrome (Multi-Tab) ---
Write-Host "-> Launching Chrome Tabs..." -ForegroundColor Cyan
# This opens Chrome with all your URLs as separate tabs in one window
Start-Process "chrome.exe" -ArgumentList $Urls


# 5. Utilities
Write-Host "-> Opening Scratchpads"
Start-Process "C:\Program Files (x86)\Notepad++\notepad++.exe"


Write-Host "🚀 System online. Happy coding!" -ForegroundColor Green