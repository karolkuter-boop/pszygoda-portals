[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BootstrapJar,

    [string]$OutputZip = (Join-Path $PSScriptRoot '..\Pszygoda-Portals-AutoUpdate-1.0.0-portals.18-r13.zip')
)

$ErrorActionPreference = 'Stop'

$systemTempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
function Assert-SafeTaskTempPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Prefix
    )
    $resolved = [System.IO.Path]::GetFullPath($Path)
    $tempPrefix = $systemTempRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($tempPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not [System.IO.Path]::GetFileName($resolved).StartsWith($Prefix, [System.StringComparison]::Ordinal)) {
        throw "Odmowa operacji na niebezpiecznej sciezce tymczasowej: $resolved"
    }
    return $resolved
}

$sourceDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\distribution\prism-autoupdate'))
$bootstrapPath = [System.IO.Path]::GetFullPath($BootstrapJar)
$outputPath = [System.IO.Path]::GetFullPath($OutputZip)

if (-not (Test-Path -LiteralPath $bootstrapPath -PathType Leaf)) {
    throw "Nie znaleziono packwiz-installer-bootstrap.jar: $bootstrapPath"
}

$instanceCfg = Get-Content -Raw -LiteralPath (Join-Path $sourceDir 'instance.cfg')
$installationGuide = Get-Content -Raw -LiteralPath (Join-Path $sourceDir 'README-INSTALACJA.txt')
if ($instanceCfg -match '(?im)^JavaPath=' -or
    $instanceCfg -match '(?im)^OverrideJavaLocation=true$' -or
    $instanceCfg -match '(?i)[A-Z]:[/\\]Users[/\\]' -or
    $installationGuide -match '(?i)[A-Z]:[/\\]Users[/\\]') {
    throw 'Szablon zawiera nieprzenosna, lokalna konfiguracje Javy.'
}
if ($instanceCfg -notmatch '(?im)^AutomaticJava=true$') {
    throw 'Szablon musi pozwalac Prismowi automatycznie dobrac Jave 21.'
}
if ($instanceCfg -notmatch '(?m)^PreLaunchCommand=cmd\.exe /D /S /C call \\"%INST_MC_DIR%\\\\packwiz-update\.cmd\\"$') {
    throw 'PreLaunchCommand nie uruchamia przenosnego resolvera z INST_MC_DIR.'
}

$launcherPath = Join-Path $sourceDir 'packwiz-update.cmd'
$launcher = Get-Content -Raw -LiteralPath $launcherPath
if ($launcher -match '(?i)[A-Z]:[/\\]Users[/\\]' -or $launcher -match '\$INST_JAVA') {
    throw 'Launcher zawiera sciezke autora albo zaleznosc od podstawienia $INST_JAVA.'
}
if ($launcher -notmatch 'CANDIDATE_MAJOR' -or
    $launcher -notmatch '"21"' -or
    $launcher -notmatch 'PSZYGODA_PACKWIZ_RESOLVE_ONLY' -or
    $launcher -notmatch [regex]::Escape('https://raw.githubusercontent.com/karolkuter-boop/pszygoda-portals/refs/heads/main/pack.toml')) {
    throw 'Launcher nie zawiera walidacji Javy 21, self-testu lub poprawnego kanalu Packwiz.'
}

function Get-JavaMajor {
    param([Parameter(Mandatory = $true)][string]$JavaExe)

    if (-not (Test-Path -LiteralPath $JavaExe -PathType Leaf)) {
        return $null
    }

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $JavaExe
    $startInfo.ArgumentList.Add('-version')
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::Start($startInfo)
    $output = $process.StandardOutput.ReadToEnd() + "`n" + $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne 0 -or $output -notmatch '(?im)version\s+"(?<version>\d+(?:\.\d+)*)') {
        return $null
    }

    $parts = $Matches.version.Split('.')
    if ($parts[0] -eq '1' -and $parts.Count -gt 1) {
        return [int]$parts[1]
    }
    return [int]$parts[0]
}

function Find-Java21 {
    $candidates = [System.Collections.Generic.List[string]]::new()
    if ($env:JAVA_HOME) {
        $candidates.Add((Join-Path $env:JAVA_HOME 'bin\java.exe'))
    }
    if ($env:APPDATA) {
        Get-ChildItem -Path (Join-Path $env:APPDATA 'PrismLauncher\java\*\bin\java.exe') -File -ErrorAction SilentlyContinue |
            ForEach-Object { $candidates.Add($_.FullName) }
    }
    $pathJava = Get-Command java.exe -ErrorAction SilentlyContinue
    if ($pathJava) {
        $candidates.Add($pathJava.Source)
    }

    foreach ($candidate in $candidates | Select-Object -Unique) {
        if ((Get-JavaMajor -JavaExe $candidate) -eq 21) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }
    throw 'Self-test dystrybucji wymaga lokalnej Javy 21.'
}

function Test-PortableResolver {
    param(
        [Parameter(Mandatory = $true)][string]$Launcher,
        [Parameter(Mandatory = $true)][string]$JavaExe
    )

    $testRoot = Assert-SafeTaskTempPath `
        -Path (Join-Path $systemTempRoot ('pszygoda-portals-resolver-' + [guid]::NewGuid())) `
        -Prefix 'pszygoda-portals-resolver-'
    $testMinecraft = Join-Path $testRoot 'instances\Portable Test\minecraft'
    $testRuntime = Join-Path $testRoot 'java\java-runtime-delta'
    $javaHome = Split-Path -Parent (Split-Path -Parent $JavaExe)
    New-Item -ItemType Directory -Path $testMinecraft -Force | Out-Null
    New-Item -ItemType Directory -Path (Split-Path -Parent $testRuntime) -Force | Out-Null

    try {
        Copy-Item -LiteralPath $Launcher -Destination (Join-Path $testMinecraft 'packwiz-update.cmd')
        New-Item -ItemType Junction -Path $testRuntime -Target $javaHome | Out-Null

        $invokeResolver = {
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $env:ComSpec
            $startInfo.Arguments = '/D /S /C call "%INST_MC_DIR%\packwiz-update.cmd"'
            $startInfo.WorkingDirectory = $sourceDir
            $startInfo.UseShellExecute = $false
            $startInfo.CreateNoWindow = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.Environment.Remove('INST_JAVA') | Out-Null
            $startInfo.Environment.Remove('PSZYGODA_JAVA') | Out-Null
            $startInfo.Environment.Remove('JAVA_HOME') | Out-Null
            $startInfo.Environment['APPDATA'] = Join-Path $testRoot 'empty-appdata'
            $startInfo.Environment['LOCALAPPDATA'] = Join-Path $testRoot 'empty-localappdata'
            $startInfo.Environment['PATH'] = Join-Path $env:SystemRoot 'System32'
            $startInfo.Environment['INST_MC_DIR'] = $testMinecraft
            $startInfo.Environment['PSZYGODA_PACKWIZ_RESOLVE_ONLY'] = '1'

            $process = [System.Diagnostics.Process]::Start($startInfo)
            $output = $process.StandardOutput.ReadToEnd() + "`n" + $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            [pscustomobject]@{ ExitCode = $process.ExitCode; Output = $output.Trim() }
        }

        $portable = & $invokeResolver
        if ($portable.ExitCode -ne 0 -or
            $portable.Output -notmatch '(?m)^\[Pszygoda Portals\] Java 21:' -or
            $portable.Output -notlike ('*' + $testRuntime + '*')) {
            throw "Przenosny resolver Javy nie przeszedl self-testu (kod $($portable.ExitCode)):`n$($portable.Output)"
        }

        Remove-Item -LiteralPath $testRuntime -Force
        $customJava = Join-Path (Split-Path -Parent $JavaExe) 'javaw.exe'
        if (-not (Test-Path -LiteralPath $customJava -PathType Leaf)) {
            $customJava = $JavaExe
        }
        [System.IO.File]::WriteAllText(
            (Join-Path (Split-Path -Parent $testMinecraft) 'instance.cfg'),
            "[General]`r`nJavaPath=$($customJava.Replace('\', '/'))`r`n",
            [System.Text.UTF8Encoding]::new($false)
        )

        $custom = & $invokeResolver
        if ($custom.ExitCode -ne 0 -or
            $custom.Output -notmatch '(?m)^\[Pszygoda Portals\] Java 21:' -or
            $custom.Output -notlike ('*' + (Split-Path -Parent $JavaExe) + '*')) {
            throw "Resolver wlasnej JavaPath nie przeszedl self-testu (kod $($custom.ExitCode)):`n$($custom.Output)"
        }

        return "portable: $($portable.Output)`ncustom: $($custom.Output)"
    }
    finally {
        if (Test-Path -LiteralPath $testRoot) {
            $safeTestRoot = Assert-SafeTaskTempPath -Path $testRoot -Prefix 'pszygoda-portals-resolver-'
            Remove-Item -LiteralPath $safeTestRoot -Recurse -Force
        }
    }
}

$resolverTest = Test-PortableResolver -Launcher $launcherPath -JavaExe (Find-Java21)

$stageDir = Assert-SafeTaskTempPath `
    -Path (Join-Path $systemTempRoot ('pszygoda-portals-dist-' + [guid]::NewGuid())) `
    -Prefix 'pszygoda-portals-dist-'
$stageMinecraft = Join-Path $stageDir 'minecraft'
New-Item -ItemType Directory -Path $stageMinecraft -Force | Out-Null

try {
    Copy-Item -LiteralPath (Join-Path $sourceDir '.packignore') -Destination $stageDir
    Copy-Item -LiteralPath (Join-Path $sourceDir 'instance.cfg') -Destination $stageDir
    Copy-Item -LiteralPath (Join-Path $sourceDir 'mmc-pack.json') -Destination $stageDir
    Copy-Item -LiteralPath (Join-Path $sourceDir 'README-INSTALACJA.txt') -Destination $stageDir
    Copy-Item -LiteralPath $bootstrapPath -Destination (Join-Path $stageMinecraft 'packwiz-installer-bootstrap.jar')
    Copy-Item -LiteralPath $launcherPath -Destination (Join-Path $stageMinecraft 'packwiz-update.cmd')

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
            'minecraft/packwiz-installer-bootstrap.jar',
            'minecraft/packwiz-update.cmd'
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
        ResolverTest = $resolverTest
    }
}
finally {
    if (Test-Path -LiteralPath $stageDir) {
        $safeStageDir = Assert-SafeTaskTempPath -Path $stageDir -Prefix 'pszygoda-portals-dist-'
        Remove-Item -LiteralPath $safeStageDir -Recurse -Force
    }
}
