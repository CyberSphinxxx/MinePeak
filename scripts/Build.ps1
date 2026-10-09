param([switch]$Install)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$dotnetExe = Join-Path $repoRoot '.tools\dotnet\dotnet.exe'
$jdk = Get-ChildItem (Join-Path $repoRoot '.tools\java') -Directory | Select-Object -First 1
if (!(Test-Path $dotnetExe) -or !$jdk) { throw 'Portable SDKs are missing. See docs/IMPLEMENTATION.md.' }
if ($Install) {
    if (Get-Process PEAK -ErrorAction SilentlyContinue) { throw 'Close PEAK before installing.' }
    if (Get-Process javaw -ErrorAction SilentlyContinue) { throw 'Close Minecraft before installing.' }
}
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:JAVA_HOME = $jdk.FullName
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
$env:GRADLE_USER_HOME = Join-Path $repoRoot '.tools\gradle'
Push-Location $repoRoot
try {
    & $dotnetExe build vendor\PeakCraft\peak -c Release -p:RunThunderPipePackAfterBuild=false -p:RunThunderPipePublishAfterBuild=false -p:DeployModFiles=false --nologo
    if ($LASTEXITCODE) { throw 'PEAK build failed.' }
    Push-Location vendor\PeakCraft\fabric
    try {
        & .\gradlew.bat build --console=plain
        if ($LASTEXITCODE) { throw 'Minecraft build or tests failed.' }
    } finally { Pop-Location }
    $bundleDir = Join-Path $repoRoot 'dist\MinePeak'
    New-Item -ItemType Directory -Force $bundleDir | Out-Null
    Copy-Item 'vendor\PeakCraft\peak\artifacts\bin\PeakCraft\release\aeironnarmiento.PeakCraft.dll' $bundleDir
    Copy-Item 'vendor\PeakCraft\fabric\build\libs\skycraft-0.1.2.jar' $bundleDir
    Copy-Item 'vendor\PeakCraft\LICENSE','vendor\PeakCraft\THIRD-PARTY-NOTICES.md','UPSTREAM.md','PLAY.md' $bundleDir
    Copy-Item 'README.md' $bundleDir
    $bundleDocs = Join-Path $bundleDir 'docs'
    New-Item -ItemType Directory -Force $bundleDocs | Out-Null
    Copy-Item 'docs\*' $bundleDocs -Recurse -Force
    $binaryManifest = Get-ChildItem $bundleDir -File | Where-Object Extension -in '.dll','.jar' | ForEach-Object {
        [pscustomobject]@{ File=$_.Name; SHA256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash }
    }
    $binaryManifest | ConvertTo-Json | Set-Content (Join-Path $bundleDir 'SHA256.json') -Encoding utf8
    if ($Install) {
        if (Get-Process PEAK -ErrorAction SilentlyContinue) { throw 'Close PEAK before installing.' }
        if (Get-Process javaw -ErrorAction SilentlyContinue) { throw 'Close Minecraft before installing.' }
        Copy-Item (Join-Path $bundleDir 'aeironnarmiento.PeakCraft.dll') '.runtime\PEAK\BepInEx\plugins'
        Copy-Item (Join-Path $bundleDir 'skycraft-0.1.2.jar') '.runtime\minecraft\mods'
    }
    Write-Host "Build complete: $bundleDir"
} finally { Pop-Location }
