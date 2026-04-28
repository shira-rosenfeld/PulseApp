# Run this script on the AIR-GAPPED machine after transferring the project.
# It points Flutter to the pre-downloaded pub_cache\ directory and resolves
# all packages without any network access.

$ErrorActionPreference = 'Stop'

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$FrontendDir = Join-Path $ProjectRoot 'pulse_frontend'
$PubCacheDir = Join-Path $ProjectRoot 'pub_cache'

Write-Host "==> Flutter offline package restore"
Write-Host "    Frontend : $FrontendDir"
Write-Host "    Pub cache: $PubCacheDir"
Write-Host ""

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: 'flutter' not found in PATH. The Flutter SDK must be pre-installed."
    exit 1
}

if (-not (Test-Path (Join-Path $PubCacheDir 'hosted'))) {
    Write-Error @"
ERROR: pub_cache\ directory not found or empty.
       Run scripts\pre_download_flutter_packages.ps1 on an internet-connected
       machine first, then transfer the pub_cache\ folder here.
"@
    exit 1
}

flutter --version

Write-Host ""
Write-Host "==> Restoring packages from local cache (no network) ..."

$env:PUB_CACHE = $PubCacheDir
Push-Location $FrontendDir
try {
    flutter pub get --offline
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "==> Package restore complete."
Write-Host ""
Write-Host "    For subsequent flutter commands (build, run, test), set PUB_CACHE first:"
Write-Host "      `$env:PUB_CACHE = '$PubCacheDir'"
Write-Host "      flutter build web"
