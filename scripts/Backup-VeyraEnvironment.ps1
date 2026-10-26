#requires -Version 5.1
[CmdletBinding()]
param([string]$BackupRoot = (Join-Path $env:LOCALAPPDATA 'Veyra\backups'))

$ErrorActionPreference = 'Stop'
$backupRootFull = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\', '/')
$projectRoot = [IO.Path]::GetFullPath((Split-Path $PSScriptRoot -Parent)).TrimEnd('\', '/')
$forbiddenRoots = @($projectRoot, $env:OneDrive, $env:OneDriveCommercial, $env:OneDriveConsumer) | Where-Object { $_ }
foreach ($root in $forbiddenRoots) {
    $fullRoot = [IO.Path]::GetFullPath($root).TrimEnd('\', '/')
    if ($backupRootFull.Equals($fullRoot, [StringComparison]::OrdinalIgnoreCase) -or
        $backupRootFull.StartsWith($fullRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'La copia debe quedar fuera del proyecto y de OneDrive.'
    }
}

$sources = @()
$package = Get-AppxPackage -Name 'SpotifyAB.SpotifyMusic' | Select-Object -First 1
if ($package) {
    $sources += [pscustomobject]@{
        Id = 'spotify-store'
        Root = Join-Path $env:LOCALAPPDATA ('Packages\' + $package.PackageFamilyName + '\LocalState\Spotify')
        Kind = 'Spotify'
    }
}
$sources += [pscustomobject]@{ Id = 'spotify-desktop'; Root = (Join-Path $env:APPDATA 'Spotify'); Kind = 'Spotify' }
$sources += [pscustomobject]@{ Id = 'spicetify-roaming'; Root = (Join-Path $env:APPDATA 'spicetify'); Kind = 'Spicetify' }
$sources += [pscustomobject]@{ Id = 'spicetify-local'; Root = (Join-Path $env:LOCALAPPDATA 'spicetify'); Kind = 'Spicetify' }
$sources += [pscustomobject]@{ Id = 'spicetify-home'; Root = (Join-Path $env:USERPROFILE '.config\spicetify'); Kind = 'Spicetify' }

$snapshotId = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8)
$snapshotPath = Join-Path $backupRootFull $snapshotId
New-Item -ItemType Directory -Path $snapshotPath -Force | Out-Null
$items = @()
$sourceIndex = @()
foreach ($source in $sources) {
    if (-not (Test-Path -LiteralPath $source.Root -PathType Container)) { continue }
    $rootPath = [IO.Path]::GetFullPath($source.Root).TrimEnd('\', '/')
    $sourceIndex += [pscustomobject]@{ Id = $source.Id; Root = $rootPath; Kind = $source.Kind }
    $files = @()
    if ($source.Kind -eq 'Spotify') {
        foreach ($name in @('prefs', 'content_settings', 'device_settings', 'user_settings')) {
            $candidate = Join-Path $rootPath $name
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $files += Get-Item -LiteralPath $candidate }
        }
        $usersPath = Join-Path $rootPath 'Users'
        if (Test-Path -LiteralPath $usersPath -PathType Container) {
            foreach ($userDirectory in (Get-ChildItem -LiteralPath $usersPath -Directory)) {
                $candidate = Join-Path $userDirectory.FullName 'prefs'
                if (Test-Path -LiteralPath $candidate -PathType Leaf) { $files += Get-Item -LiteralPath $candidate }
            }
        }
    } else {
        $candidate = Join-Path $rootPath 'config-xpui.ini'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { $files += Get-Item -LiteralPath $candidate }
        foreach ($folder in @('Themes', 'Extensions', 'CustomApps')) {
            $candidate = Join-Path $rootPath $folder
            if (Test-Path -LiteralPath $candidate -PathType Container) {
                $files += Get-ChildItem -LiteralPath $candidate -File -Recurse
            }
        }
    }
    foreach ($file in $files) {
        if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'No se copian enlaces o puntos de reanalisis.' }
        $relativePath = $file.FullName.Substring($rootPath.Length + 1)
        $storedPath = Join-Path $source.Id $relativePath
        $destination = Join-Path $snapshotPath $storedPath
        New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
        $stable = $false
        for ($attempt = 0; $attempt -lt 3; $attempt++) {
            $before = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
            $copied = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
            $after = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            if ($before -eq $copied -and $copied -eq $after) { $stable = $true; break }
        }
        if (-not $stable) { throw 'Un archivo esta cambiando. Repite la copia con Spotify cerrado.' }
        $items += [pscustomobject]@{
            SourceId = $source.Id; RelativePath = $relativePath; StoredPath = $storedPath
            SHA256 = $copied; Bytes = (Get-Item -LiteralPath $destination).Length
        }
    }
}
if ($items.Count -eq 0) { throw 'No se encontraron archivos de configuracion. La copia no es valida.' }
$startup = @()
$runKey = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
if ($runKey) {
    $startup = @($runKey.PSObject.Properties | Where-Object { $_.Name -match '^(Spotify|Skipify|Spicetify|Veyra)$' } |
        ForEach-Object { [pscustomobject]@{ Name = $_.Name; Value = $_.Value } })
}
$manifest = [ordered]@{
    SchemaVersion = 1; CreatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    Scope = 'Preferences and customizations only; not an authenticated session or cache backup'
    SpotifyWasRunning = [bool](Get-Process Spotify -ErrorAction SilentlyContinue)
    Sources = @($sourceIndex); Files = @($items); StartupReference = @($startup)
}
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $snapshotPath 'manifest.json') -Encoding UTF8
[pscustomobject]@{
    BackupPath = $snapshotPath; Files = $items.Count
    Bytes = ($items | Measure-Object Bytes -Sum).Sum
    Verified = $true
}
