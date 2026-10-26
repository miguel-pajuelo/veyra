#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)][string]$BackupPath,
    [string]$DestinationDirectory
)

$ErrorActionPreference = 'Stop'
$backupFull = (Resolve-Path -LiteralPath $BackupPath).Path.TrimEnd('\', '/')
$manifest = Get-Content -LiteralPath (Join-Path $backupFull 'manifest.json') -Raw | ConvertFrom-Json
if ($manifest.SchemaVersion -ne 1 -or @($manifest.Files).Count -eq 0) { throw 'Manifiesto no compatible o vacio.' }
$isDrill = -not [string]::IsNullOrWhiteSpace($DestinationDirectory)
if ($isDrill) {
    $drillRoot = [IO.Path]::GetFullPath($DestinationDirectory).TrimEnd('\', '/')
    if (Test-Path -LiteralPath $drillRoot) { throw 'El destino del ensayo debe ser una carpeta nueva.' }
    # A drill may live in LOCALAPPDATA/Veyra/restore-drills, never inside a live source or the snapshot.
    foreach ($root in @($backupFull) + @($manifest.Sources | ForEach-Object { $_.Root })) {
        $rootFull = [IO.Path]::GetFullPath($root).TrimEnd('\', '/')
        if ($drillRoot.Equals($rootFull, [StringComparison]::OrdinalIgnoreCase) -or
            $drillRoot.StartsWith($rootFull + '\', [StringComparison]::OrdinalIgnoreCase)) {
            throw 'El ensayo no puede escribirse dentro de una fuente original ni de la copia.'
        }
    }
} elseif ((Get-Process Spotify -ErrorAction SilentlyContinue) -and -not $WhatIfPreference) {
    throw 'Cierra Spotify antes de restaurar la configuracion real. Puedes usar -WhatIf o un destino de ensayo.'
}

# Validate every item and hash before writing any file.
$operations = @()
foreach ($item in @($manifest.Files)) {
    $sourceMatches = @($manifest.Sources | Where-Object { $_.Id -eq $item.SourceId })
    if ($sourceMatches.Count -ne 1) { throw 'Identificador de fuente no valido.' }
    foreach ($relative in @([string]$item.RelativePath, [string]$item.StoredPath)) {
        if ([IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[\\/])\.\.([\\/]|$)' -or $relative.Contains(':')) {
            throw 'El manifiesto contiene una ruta relativa no valida.'
        }
    }
    $stored = [IO.Path]::GetFullPath((Join-Path $backupFull $item.StoredPath))
    if (-not $stored.StartsWith($backupFull + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Ruta fuera de la copia.' }
    if ((Get-FileHash -LiteralPath $stored -Algorithm SHA256).Hash -ne $item.SHA256) { throw 'Fallo de integridad: no se restaurara ningun archivo.' }
    if ($isDrill) {
        $destination = Join-Path $drillRoot $item.StoredPath
        $destinationRoot = $drillRoot
    } else {
        $destinationRoot = [IO.Path]::GetFullPath([string]$sourceMatches[0].Root).TrimEnd('\', '/')
        $allowedRoots = @($env:APPDATA, $env:LOCALAPPDATA, (Join-Path $env:USERPROFILE '.config\spicetify'))
        $allowed = $false
        foreach ($root in $allowedRoots) {
            $rootFull = [IO.Path]::GetFullPath($root).TrimEnd('\', '/')
            if ($destinationRoot.StartsWith($rootFull + '\', [StringComparison]::OrdinalIgnoreCase) -or
                $destinationRoot.Equals($rootFull, [StringComparison]::OrdinalIgnoreCase)) { $allowed = $true }
        }
        if (-not $allowed) { throw 'Fuente fuera de las ubicaciones de configuracion permitidas.' }
        $destination = Join-Path $destinationRoot $item.RelativePath
    }
    $destination = [IO.Path]::GetFullPath($destination)
    if (-not $destination.StartsWith($destinationRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Destino fuera de su raiz.' }
    $operations += [pscustomobject]@{ Source = $stored; Destination = $destination; SHA256 = $item.SHA256; StoredPath = $item.StoredPath }
}

$restored = 0
$preRestorePath = $null
foreach ($operation in $operations) {
    if ($PSCmdlet.ShouldProcess($operation.Destination, $(if ($isDrill) { 'Ensayar restauracion' } else { 'Preservar archivo actual y restaurar configuracion' }))) {
        if (-not $isDrill -and (Test-Path -LiteralPath $operation.Destination -PathType Leaf)) {
            if (-not $preRestorePath) {
                $preRestorePath = Join-Path $env:LOCALAPPDATA ('Veyra\pre-restore\' + [guid]::NewGuid().ToString('N'))
            }
            $previous = Join-Path $preRestorePath $operation.StoredPath
            New-Item -ItemType Directory -Path (Split-Path $previous -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $operation.Destination -Destination $previous
            if ((Get-FileHash -LiteralPath $previous -Algorithm SHA256).Hash -ne
                (Get-FileHash -LiteralPath $operation.Destination -Algorithm SHA256).Hash) { throw 'No se pudo preservar el archivo actual.' }
        }
        New-Item -ItemType Directory -Path (Split-Path $operation.Destination -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $operation.Source -Destination $operation.Destination -Force
        if ((Get-FileHash -LiteralPath $operation.Destination -Algorithm SHA256).Hash -ne $operation.SHA256) { throw 'La verificacion posterior fallo.' }
        $restored++
    }
}
[pscustomobject]@{ Mode = $(if ($isDrill) { 'Drill' } else { 'Original' }); Planned = $operations.Count; Restored = $restored; PreviousFiles = $preRestorePath }
