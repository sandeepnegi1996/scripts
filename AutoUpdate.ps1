# Stop the script if an error occurs
$ErrorActionPreference = "Stop"

# The "Super-Command"
# --all: Update everything
# --include-unknown: Catch apps with weird versioning
# --accept-package-agreements: Say "Yes" to licenses automatically
# --accept-source-agreements: Say "Yes" to Microsoft's source terms
# --silent: Try to hide the installer UI
#winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --silent

winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --silent > "D:\priyusandy\sandy\code\scripts\update_log.txt"