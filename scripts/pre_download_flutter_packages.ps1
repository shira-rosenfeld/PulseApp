# Run this script on an internet-connected machine BEFORE deploying to the
# air-gapped environment. It downloads all pub packages defined in
# pubspec.lock into a self-contained pub_cache\ directory inside the project,
# so they can be transferred alongside the source code.

$ErrorActionPreference = 'Stop'

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$FrontendDir = Join-Path $ProjectRoot 'pulse_frontend'
$PubCacheDir = Join-Path $ProjectRoot 'pub_cache'

Write-Host "==> Flutter offline package pre-download"
Write-Host "    Frontend : $FrontendDir"
Write-Host "    Pub cache: $PubCacheDir"
Write-Host ""

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: 'flutter' not found in PATH. Install the Flutter SDK first."
    exit 1
}

flutter --version

New-Item -ItemType Directory -Force -Path $PubCacheDir | Out-Null

Write-Host ""
Write-Host "==> Downloading packages into $PubCacheDir ..."

$env:PUB_CACHE = $PubCacheDir
Push-Location $FrontendDir
try {
    flutter pub get
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "==> Verifying cache contents ..."
$PackageCount = (Get-ChildItem -Path (Join-Path $PubCacheDir 'hosted') -Recurse -Filter 'pubspec.yaml' -ErrorAction SilentlyContinue).Count
Write-Host "    Cached packages: $PackageCount"

Write-Host ""
Write-Host "==> Pre-download complete."
Write-Host "    Transfer the following to the air-gapped machine (keep relative paths):"
Write-Host "      pub_cache\"
Write-Host "      pulse_frontend\"
Write-Host ""
Write-Host "    Then run:  scripts\restore_flutter_packages.ps1"
