# Run this script on the AIR-GAPPED machine.
# It builds the pub cache from manually downloaded .tar.gz files and then
# resolves all Flutter packages without any network access.
#
# BEFORE running this script:
#   1. On an internet-connected machine, download every URL listed in
#      scripts\flutter_package_urls.txt  (browser, download manager, or cmd curl).
#   2. Put ALL downloaded .tar.gz files into a single flat folder.
#   3. Copy that folder to this machine and pass its path via -DownloadsPath.
#
# USAGE:
#   .\scripts\restore_flutter_packages.ps1 -DownloadsPath "C:\path\to\downloads"
#
# The script also accepts the path as the first positional argument.

param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$DownloadsPath
)

$ErrorActionPreference = 'Stop'

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$FrontendDir = Join-Path $ProjectRoot 'pulse_frontend'
$PubCacheDir = Join-Path $ProjectRoot 'pub_cache'
$HostedDir   = Join-Path $PubCacheDir 'hosted\pub.dev'
$HashesDir   = Join-Path $PubCacheDir 'hosted-hashes\pub.dev'

# Exact versions and sha256 hashes from pubspec.lock
$Packages = @{
    "_fe_analyzer_shared-85.0.0" = "da0d9209ca76bde579f2da330aeb9df62b6319c834fa7baae052021b0462401f"
    "analyzer-7.6.0" = "f4ad0fea5f102201015c9aae9d93bc02f75dd9491529a8c21f88d17a8523d44c"
    "analyzer_plugin-0.13.4" = "a5ab7590c27b779f3d4de67f31c4109dbe13dd7339f86461a6f2a8ab2594d8ce"
    "args-2.7.0" = "d0481093c50b1da8910eb0bb301626d4d8eb7284aa739614d2b394ee09e3ea04"
    "async-2.12.0" = "d2872f9c19731c2e5f10444b14686eb7cc85c76274bd6c16e1816bff9a3bab63"
    "boolean_selector-2.1.2" = "8aab1771e1243a5063b8b0ff68042d67334e3feab9e95b9490f9a6ebf73b42ea"
    "build-2.5.4" = "51dc711996cbf609b90cbe5b335bbce83143875a9d58e4b5c6d3c4f684d3dda7"
    "build_config-1.1.2" = "4ae2de3e1e67ea270081eaee972e1bd8f027d459f249e0f1186730784c2e7e33"
    "build_daemon-4.1.1" = "bf05f6e12cfea92d3c09308d7bcdab1906cd8a179b023269eed00c071004b957"
    "build_resolvers-2.5.4" = "ee4257b3f20c0c90e72ed2b57ad637f694ccba48839a821e87db762548c22a62"
    "build_runner-2.5.4" = "382a4d649addbfb7ba71a3631df0ec6a45d5ab9b098638144faf27f02778eb53"
    "build_runner_core-9.1.2" = "85fbbb1036d576d966332a3f5ce83f2ce66a40bea1a94ad2d5fc29a19a0d3792"
    "built_collection-5.1.1" = "376e3dd27b51ea877c28d525560790aee2e6fbb5f20e2f85d5081027d94e2100"
    "built_value-8.12.4" = "6ae8a6435a8c6520c7077b107e77f1fb4ba7009633259a4d49a8afd8e7efc5e9"
    "characters-1.4.0" = "f71061c654a3380576a52b451dd5532377954cf9dbd272a78fc8479606670803"
    "checked_yaml-2.0.3" = "feb6bed21949061731a7a75fc5d2aa727cf160b91af9a3e464c5e3a32e28b5ff"
    "ci-0.1.0" = "145d095ce05cddac4d797a158bc4cf3b6016d1fe63d8c3d2fbd7212590adca13"
    "cli_util-0.4.2" = "ff6785f7e9e3c38ac98b2fb035701789de90154024a75b6cb926445e83197d1c"
    "clock-1.1.2" = "fddb70d9b5277016c77a80201021d40a2247104d9f4aa7bab7157b7e3f05b84b"
    "code_builder-4.11.1" = "6a6cab2ba4680d6423f34a9b972a4c9a94ebe1b62ecec4e1a1f2cba91fd1319d"
    "collection-1.19.1" = "2f5709ae4d3d59dd8f7cd309b4e023046b57d8a6c82130785d2b0e5868084e76"
    "convert-3.1.2" = "b30acd5944035672bc15c6b7a8b47d773e41e2f17de064350988c5d02adb1c68"
    "crypto-3.0.7" = "c8ea0233063ba03258fbcf2ca4d6dadfefe14f02fab57702265467a19f27fadf"
    "custom_lint-0.7.6" = "9656925637516c5cf0f5da018b33df94025af2088fe09c8ae2ca54c53f2d9a84"
    "custom_lint_builder-0.7.6" = "6cdc8e87e51baaaba9c43e283ed8d28e59a0c4732279df62f66f7b5984655414"
    "custom_lint_core-0.7.5" = "31110af3dde9d29fb10828ca33f1dce24d2798477b167675543ce3d208dee8be"
    "custom_lint_visitor-1.0.0+7.7.0" = "4a86a0d8415a91fbb8298d6ef03e9034dc8e323a599ddc4120a0e36c433983a2"
    "dart_style-3.1.1" = "8a0e5fba27e8ee025d2ffb4ee820b4e6e2cf5e4246a6b1a477eb66866947e0bb"
    "fake_async-1.3.2" = "6a95e56b2449df2273fd8c45a662d6947ce1ebb7aafe80e550a3f68297f3cacc"
    "file-7.0.1" = "a3b4f84adafef897088c160faf7dfffb7696046cb13ae90b508c2cbc95d3b8d4"
    "fixnum-1.1.1" = "b6dc7065e46c974bc7c5f143080a6764ec7a4be6da1285ececdc37be96de53be"
    "flutter_lints-2.0.3" = "a25a15ebbdfc33ab1cd26c63a6ee519df92338a9c10f122adda92938253bef04"
    "flutter_riverpod-2.6.1" = "9532ee6db4a943a1ed8383072a2e3eeda041db5657cdf6d2acecf3c21ecbe7e1"
    "freezed-3.1.0" = "2d399f823b8849663744d2a9ddcce01c49268fb4170d0442a655bf6a2f47be22"
    "freezed_annotation-3.1.0" = "7294967ff0a6d98638e7acb774aac3af2550777accd8149c90af5b014e6d44d8"
    "frontend_server_client-4.0.0" = "f64a0333a82f30b0cca061bc3d143813a486dc086b574bfb233b7c1372427694"
    "glob-2.1.3" = "c3f1ee72c96f8f78935e18aa8cecced9ab132419e8625dc187e1c2408efc20de"
    "graphs-2.3.2" = "741bbf84165310a68ff28fe9e727332eef1407342fca52759cb21ad8177bb8d0"
    "hotreloader-4.3.0" = "bc167a1163807b03bada490bfe2df25b0d744df359227880220a5cbd04e5734b"
    "http-1.6.0" = "87721a4a50b19c7f1d49001e51409bddc46303966ce89a65af4f4e6004896412"
    "http_multi_server-3.2.2" = "aa6199f908078bb1c5efb8d8638d4ae191aac11b311132c3ef48ce352fb52ef8"
    "http_parser-4.1.2" = "178d74305e7866013777bab2c3d8726205dc5a4dd935297175b19a23a2e66571"
    "intl-0.19.0" = "d6f56758b7d3014a48af9701c085700aac781a92a87a62b1333b46d8879661cf"
    "io-1.0.5" = "dfd5a80599cf0165756e3181807ed3e77daf6dd4137caaad72d0b7931597650b"
    "js-0.7.2" = "53385261521cc4a0c4658fd0ad07a7d14591cf8fc33abbceae306ddb974888dc"
    "json_annotation-4.9.0" = "1ce844379ca14835a50d2f019a3099f419082cfdd231cd86a142af94dd5c6bb1"
    "json_serializable-6.9.5" = "c50ef5fc083d5b5e12eef489503ba3bf5ccc899e487d691584699b4bdefeea8c"
    "leak_tracker-10.0.8" = "c35baad643ba394b40aac41080300150a4f08fd0fd6a10378f8f7c6bc161acec"
    "leak_tracker_flutter_testing-3.0.9" = "f8b613e7e6a13ec79cfdc0e97638fddb3ab848452eff057653abd3edba760573"
    "leak_tracker_testing-3.0.1" = "6ba465d5d76e67ddf503e1161d1f4a6bc42306f9d66ca1e8f079a47290fb06d3"
    "lints-2.1.1" = "0a217c6c989d21039f1498c3ed9f3ed71b354e69873f13a8dfc3c9fe76f1b452"
    "logging-1.3.0" = "c8245ada5f1717ed44271ed1c26b8ce85ca3228fd2ffdb75468ab01979309d61"
    "lucide_icons_flutter-3.1.10" = "f9fc191c852901b7f8d0d5739166327bd71a0fc32ae32c1ba07501d16b966a1a"
    "matcher-0.12.17" = "dc58c723c3c24bf8d3e2d3ad3f2f9d7bd9cf43ec6feaa64181775e60190153f2"
    "material_color_utilities-0.11.1" = "f7142bb1154231d7ea5f96bc7bde4bda2a0945d2806bb11670e30b850d56bdec"
    "meta-1.16.0" = "e3641ec5d63ebf0d9b41bd43201a66e3fc79a65db5f61fc181f04cd27aab950c"
    "mime-2.0.0" = "41a20518f0cb1256669420fdba0cd90d21561e560ac240f26ef8322e45bb7ed6"
    "package_config-2.2.0" = "f096c55ebb7deb7e384101542bfba8c52696c1b56fca2eb62827989ef2353bbc"
    "path-1.9.1" = "75cca69d1490965be98c73ceaea117e8a04dd21217b37b292c9ddbec0d955bc5"
    "pool-1.5.2" = "978783255c543aa3586a1b3c21f6e9d720eb315376a915872c61ef8b5c20177d"
    "pub_semver-2.2.0" = "5bfcf68ca79ef689f8990d1160781b4bad40a3bd5e5218ad4076ddb7f4081585"
    "pubspec_parse-1.5.0" = "0560ba233314abbed0a48a2956f7f022cce7c3e1e73df540277da7544cad4082"
    "riverpod-2.6.1" = "59062512288d3056b2321804332a13ffdd1bf16df70dcc8e506e411280a72959"
    "riverpod_analyzer_utils-0.5.10" = "03a17170088c63aab6c54c44456f5ab78876a1ddb6032ffde1662ddab4959611"
    "riverpod_annotation-2.6.1" = "e14b0bf45b71326654e2705d462f21b958f987087be850afd60578fcd502d1b8"
    "riverpod_generator-2.6.5" = "44a0992d54473eb199ede00e2260bd3c262a86560e3c6f6374503d86d0580e36"
    "riverpod_lint-2.6.5" = "89a52b7334210dbff8605c3edf26cfe69b15062beed5cbfeff2c3812c33c9e35"
    "rxdart-0.28.0" = "5c3004a4a8dbb94bd4bf5412a4def4acdaa12e12f269737a5751369e12d1a962"
    "shelf-1.4.2" = "e7dd780a7ffb623c57850b33f43309312fc863fb6aa3d276a754bb299839ef12"
    "shelf_web_socket-3.0.0" = "3632775c8e90d6c9712f883e633716432a27758216dfb61bd86a8321c0580925"
    "source_gen-2.0.0" = "35c8150ece9e8c8d263337a265153c3329667640850b9304861faea59fc98f6b"
    "source_helper-1.3.7" = "a447acb083d3a5ef17f983dd36201aeea33fedadb3228fa831f2f0c92f0f3aca"
    "source_span-1.10.1" = "254ee5351d6cb365c859e20ee823c3bb479bf4a293c22d17a9f1bf144ce86f7c"
    "stack_trace-1.12.1" = "8b27215b45d22309b5cddda1aa2b19bdfec9df0e765f2de506401c071d38d1b1"
    "state_notifier-1.0.0" = "b8677376aa54f2d7c58280d5a007f9e8774f1968d1fb1c096adcb4792fba29bb"
    "stream_channel-2.1.4" = "969e04c80b8bcdf826f8f16579c7b14d780458bd97f56d107d3950fdbeef059d"
    "stream_transform-2.1.1" = "ad47125e588cfd37a9a7f86c7d6356dde8dfe89d071d293f80ca9e9273a33871"
    "string_scanner-1.4.1" = "921cd31725b72fe181906c6a94d987c78e3b98c2e205b397ea399d4054872b43"
    "term_glyph-1.2.2" = "7f554798625ea768a7518313e58f83891c7f5024f88e46e7182a4558850a4b8e"
    "test_api-0.7.4" = "fb31f383e2ee25fbbfe06b40fe21e1e458d14080e3c67e7ba0acfde4df4e0bbd"
    "timing-1.0.2" = "62ee18aca144e4a9f29d212f5a4c6a053be252b895ab14b5821996cff4ed90fe"
    "typed_data-1.4.0" = "f9049c039ebfeb4cf7a7104a675823cd72dba8297f264b6637062516699fa006"
    "uuid-4.5.3" = "1fef9e8e11e2991bb773070d4656b7bd5d850967a2456cfc83cf47925ba79489"
    "vector_math-2.1.4" = "80b3257d1492ce4d091729e3a67a60407d227c27241d6927be0130c98e741803"
    "vm_service-14.3.1" = "0968250880a6c5fe7edc067ed0a13d4bae1577fe2771dcf3010d52c4a9d3ca14"
    "watcher-1.2.1" = "1398c9f081a753f9226febe8900fce8f7d0a67163334e1c94a2438339d79d635"
    "web-1.1.1" = "868d88a33d8a87b18ffc05f9f030ba328ffefba92d6c127917a2ba740f9cfe4a"
    "web_socket-1.0.1" = "34d64019aa8e36bf9842ac014bb5d2f5586ca73df5e4d9bf5c936975cae6982c"
    "web_socket_channel-3.0.3" = "d645757fb0f4773d602444000a8131ff5d48c9e47adfe9772652dd1a4f2d45c8"
    "yaml-3.1.3" = "b9da305ac7c39faa3f030eccd175340f968459dae4af175130b3fc47e40d76ce"
}

Write-Host "==> Flutter offline package restore"
Write-Host "    Downloads : $DownloadsPath"
Write-Host "    Pub cache : $PubCacheDir"
Write-Host "    Packages  : $($Packages.Count)"
Write-Host ""

if (-not (Test-Path $DownloadsPath)) {
    Write-Error "Downloads folder not found: $DownloadsPath"
    exit 1
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "flutter not found in PATH. Install the Flutter SDK first."
    exit 1
}

New-Item -ItemType Directory -Force -Path $HostedDir  | Out-Null
New-Item -ItemType Directory -Force -Path $HashesDir  | Out-Null

$ok    = 0
$skip  = 0
$fails = @()

foreach ($entry in $Packages.GetEnumerator()) {
    $pkgKey  = $entry.Key       # e.g. "http-1.6.0"
    $sha256  = $entry.Value
    $archive = Join-Path $DownloadsPath "$pkgKey.tar.gz"
    $destDir = Join-Path $HostedDir $pkgKey
    $hashFile = Join-Path $HashesDir "$pkgKey.sha256"

    if (-not (Test-Path $archive)) {
        Write-Warning "MISSING: $pkgKey.tar.gz  (skipping)"
        $fails += $pkgKey
        continue
    }

    if (Test-Path $destDir) {
        $skip++
        continue
    }

    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    tar -xzf $archive -C $destDir 2>&1 | Out-Null
    Set-Content -Path $hashFile -Value $sha256 -NoNewline -Encoding ascii
    $ok++
}

Write-Host "==> Cache population complete."
Write-Host "    Extracted : $ok"
Write-Host "    Skipped   : $skip (already present)"
if ($fails.Count -gt 0) {
    Write-Warning "$($fails.Count) archive(s) were missing — re-download them from flutter_package_urls.txt:"
    $fails | ForEach-Object { Write-Warning "  $_.tar.gz" }
    Write-Host ""
    Write-Host "Re-run this script once you have added the missing archives."
    exit 1
}

Write-Host ""
Write-Host "==> Running: flutter pub get --offline ..."
$env:PUB_CACHE = $PubCacheDir
Push-Location $FrontendDir
try {
    flutter pub get --offline
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "==> Done. For subsequent flutter commands set PUB_CACHE first:"
Write-Host "      `$env:PUB_CACHE = '$PubCacheDir'"
Write-Host "      flutter build web"
