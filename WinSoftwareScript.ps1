# winget install -e --id Microsoft.DotNet.Framework.DeveloperPack_4
# Set-ExecutionPolicy Bypass -Scope Process -Force;
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
# Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# List of software packages to install or upgrade
$packageList = @(
    "googlechrome",
    "dotnet-6.0-sdk",
    "dotnetcore-sdk",
    "dotnetcore-2.1-sdk",
    "netfx-4.8-devpack",
    # "netfx-4.7.1-devpack",
    # "netfx-4.7.2-devpack",
    # "netfx-4.6.2-devpack",
   # "azure-cli",
    "microsoft-windows-terminal",
    "azcopy10",
    "git.install",
    "openssl",
    "powershell-core",
    "nvm",
  #  "sql-server-management-studio",
   # "visualstudio2022enterprise",
    "vscode",
    "postman",
    "fiddler",
    "terraform",
    "kubernetes-cli",
    "kubernetes-helm",
    "python3",
    "terraform-docs",
    "tflint",
     "docker-desktop",
    "jetbrainstoolbox",
    "terminals",
    "packer",
    "vagrant",
  #  "forticlientvpn",
   # "netextender",
     "openvpn",
    "keepass",
   # "nordpass",
    #"winrar",
    "notepadplusplus",
    "vlc",
    "qbittorrent",
    "miktex",
    "foxitreader",
    "coretemp",
    "figma",
    "totalcommander",
    "sumatrapdf.install",
   "discord",
    "obs-studio",
    "itunes",
    "k-litecodecpackmega",
    "steam-client",
    "sharex"
)

Write-Host "Trying to upgrade chocolatey... "

choco upgrade chocolatey

Write-Host "Installing Google chrome ignoring checksums ..."

choco install googlechrome --ignore-checksums -y


$StartTime = (Get-Date)

$installedPackages = choco list --local-only --limit-output

foreach ($package in $packageList) {
    # Check if the package is already installed
    # $installedPackage = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name = '$package'" -ErrorAction SilentlyContinue

    if ($installedPackages -match "$package") {
        # Package is not installed, so install it
        Write-Host "$package already installed, trying to upgrade ..."
        choco upgrade --yes $package
    }

    else {
        # Package is already installed, so upgrade it
        Write-Host "Installing $package..."
        choco install --yes $package
    }
}

$EndTime = (Get-Date)
$TotalTime = $EndTime - $StartTime
$TotalTimeString = $TotalTime.ToString();

Write-Host "Execution time: $TotalTimeString"

Write-Host "Software installation and upgrade completed."

# Set-ExecutionPolicy Bypass -Scope Process -Force;