[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$corepack = Get-Command corepack -ErrorAction SilentlyContinue
if ($null -eq $corepack) { throw "Corepack is required to run Pragma." }
if ([string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) { throw "LOCALAPPDATA is required on Windows." }

$shimRoot = Join-Path $env:LOCALAPPDATA "lvsea-zhuanjia\bin"
New-Item -ItemType Directory -Force -Path $shimRoot | Out-Null

$corepackPath = $corepack.Source
$pnpmShim = Join-Path $shimRoot "pnpm.cmd"
$pnpxShim = Join-Path $shimRoot "pnpx.cmd"
$pnpmContent = "@echo off`r`n`"$corepackPath`" pnpm@10.12.1 %*`r`n"
$pnpxContent = "@echo off`r`n`"$corepackPath`" pnpm@10.12.1 dlx %*`r`n"
[IO.File]::WriteAllText($pnpmShim, $pnpmContent, [Text.Encoding]::ASCII)
[IO.File]::WriteAllText($pnpxShim, $pnpxContent, [Text.Encoding]::ASCII)

if (-not (($env:Path -split ';') | Where-Object { $_ -ieq $shimRoot })) {
  $env:Path = "$shimRoot;$env:Path"
}

Write-Output $shimRoot
