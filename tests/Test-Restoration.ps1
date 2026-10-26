#requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$restoreScript = Join-Path $repoRoot 'scripts\Restore-VeyraEnvironment.ps1'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('VeyraTests\' + [guid]::NewGuid().ToString('N'))
$snapshotPath = Join-Path $testRoot 'snapshot'
$storedPath = 'spotify-store\Users\fixture-user\prefs'
$filePath = Join-Path $snapshotPath $storedPath
New-Item -ItemType Directory -Path (Split-Path $filePath -Parent) -Force | Out-Null
$expectedBytes = [byte[]](0, 1, 2, 10, 13, 65, 128, 200, 255)
[IO.File]::WriteAllBytes($filePath, $expectedBytes)
$manifest = @{
    SchemaVersion = 1
    Sources = @(@{ Id = 'spotify-store'; Root = (Join-Path $testRoot 'original'); Kind = 'Spotify' })
    Files = @(@{ SourceId = 'spotify-store'; RelativePath = 'Users\fixture-user\prefs'; StoredPath = $storedPath; SHA256 = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash; Bytes = $expectedBytes.Length })
}
$manifestPath = Join-Path $snapshotPath 'manifest.json'
function Write-FixtureManifest {
    $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
}
function Assert-Rejected {
    param([scriptblock]$Action, [string]$Description)
    $rejected = $false
    try { & $Action | Out-Null } catch { $rejected = $true }
    if (-not $rejected) { throw ('Expected rejection: ' + $Description) }
}
Write-FixtureManifest

# A successful round trip must preserve arbitrary bytes, not just text.
$destination = Join-Path $testRoot 'restored'
$result = & $restoreScript -BackupPath $snapshotPath -DestinationDirectory $destination
if ($result.Restored -ne 1) { throw 'Round trip did not restore the expected file.' }
$restoredBytes = [IO.File]::ReadAllBytes((Join-Path $destination $storedPath))
if ([Convert]::ToBase64String($restoredBytes) -ne [Convert]::ToBase64String($expectedBytes)) { throw 'Restored bytes differ.' }

# Existing drill destinations must not be silently overwritten.
Assert-Rejected { & $restoreScript -BackupPath $snapshotPath -DestinationDirectory $destination } 'existing drill destination'

# WhatIf must validate and plan while leaving the new destination absent.
$previewPath = Join-Path $testRoot 'preview'
$preview = & $restoreScript -BackupPath $snapshotPath -DestinationDirectory $previewPath -WhatIf
if ((Test-Path -LiteralPath $previewPath) -or $preview.Restored -ne 0 -or $preview.Planned -ne 1) { throw 'WhatIf wrote files or planned incorrectly.' }

# Corrupted backups must fail before creating any restored output.
[IO.File]::WriteAllBytes($filePath, [byte[]](99, 98))
$corruptDestination = Join-Path $testRoot 'corrupt-output'
Assert-Rejected { & $restoreScript -BackupPath $snapshotPath -DestinationDirectory $corruptDestination } 'corrupted backup'
if (Test-Path -LiteralPath $corruptDestination) { throw 'Corrupt backup created output.' }
[IO.File]::WriteAllBytes($filePath, $expectedBytes)

# A manifest cannot redirect a relative path outside its destination.
$manifest.Files[0].RelativePath = '..\escape.txt'
Write-FixtureManifest
$traversalDestination = Join-Path $testRoot 'traversal-output'
Assert-Rejected { & $restoreScript -BackupPath $snapshotPath -DestinationDirectory $traversalDestination } 'path traversal'
if (Test-Path -LiteralPath $traversalDestination) { throw 'Invalid path created output.' }
$manifest.Files[0].RelativePath = 'Users\fixture-user\prefs'
Write-FixtureManifest

Assert-Rejected { & $restoreScript -BackupPath $snapshotPath -DestinationDirectory (Join-Path $snapshotPath 'nested-output') } 'drill inside snapshot'
[pscustomobject]@{ Result = 'PASS'; Checks = 6; Scope = 'Isolated file restoration; no Spotify interaction' }
