[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BootstrapJar,

    [string]$OutputZip = (Join-Path $PSScriptRoot '..\Pszygoda-Portals-AutoUpdate-1.0.0-portals.8.zip')
)

$ErrorActionPreference = 'Stop'

$sourceDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\distribution\prism-autoupdate'))
$bootstrapPath = [System.IO.Path]::GetFullPath($BootstrapJar)
$outputPath = [System.IO.Path]::GetFullPath($OutputZip)

if (-not (Test-Path -LiteralPath $bootstrapPath -PathType Leaf)) {
    throw "Nie znaleziono packwiz-installer-bootstrap.jar: $bootstrapPath"
}

$instanceCfg = Get-Content -Raw -LiteralPath (Join-Path $sourceDir 'instance.cfg')
if ($instanceCfg -match '(?im)^JavaPath=' -or
    $instanceCfg -match '(?im)^OverrideJavaLocation=true$' -or
    $instanceCfg -match '(?i)[A-Z]:[/\\]Users[/\\]') {
    throw 'Szablon zawiera nieprzenosna, lokalna konfiguracje Javy.'
}
if ($instanceCfg -notmatch '(?im)^AutomaticJava=false$') {
    throw 'Szablon musi korzystac z globalnej Javy Prism przed wykonaniem pre-launch.'
}
if ($instanceCfg -notmatch '(?m)^PreLaunchCommand=\\"\$INST_JAVA\\" -jar packwiz-installer-bootstrap\.jar -g https://raw\.githubusercontent\.com/karolkuter-boop/pszygoda-portals/refs/heads/main/pack\.toml$') {
    throw 'PreLaunchCommand nie uzywa przenosnego $INST_JAVA lub ma zly kanal Packwiz.'
}

$stageDir = Join-Path ([System.IO.Path]::GetTempPath()) ('pszygoda-portals-dist-' + [guid]::NewGuid())
$stageMinecraft = Join-Path $stageDir 'minecraft'
New-Item -ItemType Directory -Path $stageMinecraft -Force | Out-Null

try {
    Copy-Item -LiteralPath (Join-Path $sourceDir '.packignore') -Destination $stageDir
    Copy-Item -LiteralPath (Join-Path $sourceDir 'instance.cfg') -Destination $stageDir
    Copy-Item -LiteralPath (Join-Path $sourceDir 'mmc-pack.json') -Destination $stageDir
    Copy-Item -LiteralPath (Join-Path $sourceDir 'README-INSTALACJA.txt') -Destination $stageDir
    Copy-Item -LiteralPath $bootstrapPath -Destination (Join-Path $stageMinecraft 'packwiz-installer-bootstrap.jar')

    $outputParent = Split-Path -Parent $outputPath
    New-Item -ItemType Directory -Path $outputParent -Force | Out-Null
    if (Test-Path -LiteralPath $outputPath) {
        Remove-Item -LiteralPath $outputPath -Force
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $stageDir,
        $outputPath,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )

    $archive = [System.IO.Compression.ZipFile]::OpenRead($outputPath)
    try {
        $required = @(
            '.packignore',
            'instance.cfg',
            'mmc-pack.json',
            'README-INSTALACJA.txt',
            'minecraft/packwiz-installer-bootstrap.jar'
        )
        $entries = @($archive.Entries | ForEach-Object { $_.FullName.Replace('\\', '/') })
        foreach ($entry in $required) {
            if ($entry -notin $entries) {
                throw "Brak pliku w ZIP: $entry"
            }
        }
    }
    finally {
        $archive.Dispose()
    }

    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $outputPath
    [pscustomobject]@{
        Path = $outputPath
        Length = (Get-Item -LiteralPath $outputPath).Length
        SHA256 = $hash.Hash
    }
}
finally {
    if (Test-Path -LiteralPath $stageDir) {
        Remove-Item -LiteralPath $stageDir -Recurse -Force
    }
}
