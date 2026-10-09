$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$toolsRoot = Join-Path $repoRoot '.tools'
$manifest = Get-Content (Join-Path $PSScriptRoot 'toolchains.json') -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force $toolsRoot | Out-Null

function Get-VerifiedArchive($Url, $Path, $Algorithm, $ExpectedHash) {
    if (!(Test-Path -LiteralPath $Path)) {
        Write-Host "Downloading $([System.IO.Path]::GetFileName($Path))"
        Invoke-WebRequest -Uri $Url -OutFile $Path
    }
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm $Algorithm).Hash
    if ($actual -ne $ExpectedHash) {
        throw "Hash mismatch for $Path. The archive has not been extracted. Remove that archive and retry."
    }
}

$dotnetRoot = Join-Path $toolsRoot 'dotnet'
if (!(Test-Path (Join-Path $dotnetRoot 'dotnet.exe'))) {
    $archivePath = Join-Path $toolsRoot 'dotnet-sdk.zip'
    Get-VerifiedArchive $manifest.DotnetUrl $archivePath 'SHA512' $manifest.DotnetHash
    Expand-Archive -LiteralPath $archivePath -DestinationPath $dotnetRoot -Force
}
$javaRoot = Join-Path $toolsRoot 'java'
$existingJdk = Get-ChildItem $javaRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName 'bin\java.exe') } | Select-Object -First 1
if (!$existingJdk) {
    $archivePath = Join-Path $toolsRoot 'jdk.zip'
    Get-VerifiedArchive $manifest.JdkUrl $archivePath 'SHA256' $manifest.JdkHash
    Expand-Archive -LiteralPath $archivePath -DestinationPath $javaRoot -Force
}
Write-Host "Portable toolchains available in $toolsRoot. No machine PATH change was made."
