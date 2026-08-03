$ErrorActionPreference = 'Stop'

function Write-AsciiFile {
    param([string]$Path, [string]$Content)
    if ((-not (Test-Path -LiteralPath $Path)) -or
        ([System.IO.File]::ReadAllText($Path) -ne $Content)) {
        [System.IO.File]::WriteAllText($Path, $Content, [System.Text.Encoding]::ASCII)
    }
}

function Get-UPXHelp {
    param([string]$BinaryPath)
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $BinaryPath
    $startInfo.Arguments = '--help'
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw "Could not start UPX binary: $BinaryPath"
        }
        $output = $process.StandardOutput.ReadToEnd()
        $errorOutput = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) {
            throw "UPX --help failed with exit code $($process.ExitCode): $BinaryPath`r`n$errorOutput"
        }
        if (-not [string]::IsNullOrEmpty($errorOutput)) {
            $output += $errorOutput
        }
        return $output
    }
    finally {
        $process.Dispose()
    }
}

$upxFiles = @(
    [PSCustomObject]@{ ResourceName = 'UPX1'; BinaryName = 'UPX1_x86.bin' },
    [PSCustomObject]@{ ResourceName = 'UPX2'; BinaryName = 'UPX2_x86.bin' },
    [PSCustomObject]@{ ResourceName = 'UPX3'; BinaryName = 'UPX3_x86.bin' }
)

$versions = foreach ($upxFile in $upxFiles) {
    $binaryPath = Join-Path $PSScriptRoot $upxFile.BinaryName
    if (-not (Test-Path -LiteralPath $binaryPath -PathType Leaf)) {
        throw "UPX binary not found: $binaryPath"
    }

    $fileVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($binaryPath).FileVersion
    if ([string]::IsNullOrWhiteSpace($fileVersion)) {
        throw "FileVersion not found: $binaryPath"
    }

    $version = [regex]::Replace($fileVersion.Trim(), '\s+\([^)]*\)$', '')
    if ($version -notmatch '^\d+(\.\d+)+$') {
        throw "Invalid UPX FileVersion '$fileVersion': $binaryPath"
    }

    $help = Get-UPXHelp $binaryPath
    $help = $help.Replace("Usage: $($upxFile.BinaryName)", 'Usage: upx.exe')
    $help = [regex]::Replace($help, '\r?\n', "`r`n")
    $help = [regex]::Replace($help, '(\r\n)+\z', '') + "`r`n"
    $helpPath = Join-Path $PSScriptRoot "$($upxFile.ResourceName)_Help.txt"
    Write-AsciiFile $helpPath $help

    "'UPX $version'"
}

$content = @(
    '  aUPXVersions: array[TUPXVersions] of string =',
    "    ($($versions -join ', '), 'Custom');"
) -join "`r`n"
$content += "`r`n"

$outputPath = Join-Path $PSScriptRoot 'UPXVersions.inc'
Write-AsciiFile $outputPath $content
$resourceCompiler = Get-Command 'brcc32.exe' -ErrorAction Stop
$resourceScript = Join-Path $PSScriptRoot 'resources.rc'
$resourceOutput = Join-Path (Split-Path $PSScriptRoot) 'resources.res'
Push-Location (Split-Path $PSScriptRoot)
try {
    & $resourceCompiler.Source "-fo$resourceOutput" $resourceScript
    if ($LASTEXITCODE -ne 0) {
        throw "Resource compilation failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}