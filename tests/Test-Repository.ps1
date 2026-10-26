#requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$required = @(
    'README.md', 'LICENSE', 'THIRD_PARTY_NOTICES.md', 'CHANGELOG.md', 'ROADMAP.md', '.gitignore', '.gitattributes',
    'docs/architecture.md', 'docs/compatibility.md', 'docs/installation.md', 'docs/restoration.md',
    'docs/troubleshooting.md', 'docs/validation.md', 'docs/environment.md',
    'integration/README.md', 'theme/README.md', 'scripts/Backup-VeyraEnvironment.ps1',
    'scripts/Restore-VeyraEnvironment.ps1', 'tests/Test-Restoration.ps1', '.github/workflows/validate.yml'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { throw ('Missing required file: ' + $relative) }
}
$tracked = @(& git -C $root -c core.quotepath=false ls-files)
if ($LASTEXITCODE -ne 0 -or $tracked.Count -eq 0) { throw 'No tracked content. Stage explicit public paths before this check.' }
$privatePattern = '(^|/)(\.codex|backups|restore-drills|pre-restore|logs|node_modules|bin|obj)(/|$)|(^|/)(prefs|manifest\.json|config-xpui\.ini|\.env)(\.|$)|\.(key|pem|pfx|p12|log|exe|dll|zip)$'
foreach ($relative in $tracked) {
    if ($relative -match $privatePattern) { throw ('Private or generated file tracked: ' + $relative) }
    $fullPath = Join-Path $root $relative
    if ($relative -match '\.(md|ps1|html|yml|json)$') {
        $content = Get-Content -LiteralPath $fullPath -Raw -Encoding UTF8
        if ($content -match 'gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----') {
            throw ('Possible credential in public file: ' + $relative)
        }
        if ($content -match '(?i)[A-Z]:\\Users\\(?!Public(?:\\|$))') { throw ('Personal absolute path in public file: ' + $relative) }
        if ($relative.EndsWith('.md')) {
            foreach ($match in [regex]::Matches($content, '\[[^\]]*\]\(([^)]+)\)')) {
                $target = $match.Groups[1].Value
                if ($target -match '^[a-zA-Z][a-zA-Z0-9+.-]*:' -or $target.StartsWith('#')) { continue }
                $target = ($target -split '#')[0]
                if ($target -and -not (Test-Path -LiteralPath (Join-Path (Split-Path $fullPath -Parent) $target))) {
                    throw ('Broken local link in ' + $relative + ': ' + $target)
                }
            }
        }
    }
    if ($relative.EndsWith('.ps1')) {
        $tokens = $null; $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($fullPath, [ref]$tokens, [ref]$parseErrors) | Out-Null
        if (@($parseErrors).Count -gt 0) { throw ('PowerShell parse error: ' + $relative) }
    }
}
$originalHash = (Get-FileHash -LiteralPath (Join-Path $root 'Veyra_Roadmap_y_Contexto_del_Proyecto.html') -Algorithm SHA256).Hash
if ($originalHash -ne 'B9A107DD52D99346261EB77144F2FDC40EF0E314A0FAF14C7833FACAB45ED980') { throw 'The original roadmap changed.' }

$patterns = @('.codex/private.json', 'backups/prefs', 'logs/example.log', '.env', 'integration/bin/app.exe', 'local/manifest.json', 'config-xpui.ini')
foreach ($candidate in $patterns) {
    & git -C $root check-ignore -q -- $candidate
    if ($LASTEXITCODE -ne 0) { throw ('Private path not ignored: ' + $candidate) }
}
$validation = Get-Content -LiteralPath (Join-Path $root 'docs/validation.md') -Raw -Encoding UTF8
foreach ($number in 1..12) {
    if ($validation -notmatch ('\bR' + $number.ToString('00') + '\b')) { throw 'Missing requirement traceability.' }
}
foreach ($number in 1..10) {
    if ($validation -notmatch ('\bT' + $number.ToString('00') + '\b')) { throw 'Missing acceptance test traceability.' }
}
[pscustomobject]@{ Result = 'PASS'; PublicFiles = $tracked.Count; RequiredFiles = $required.Count; PrivacyPatterns = $patterns.Count; OriginalPreserved = $true }
