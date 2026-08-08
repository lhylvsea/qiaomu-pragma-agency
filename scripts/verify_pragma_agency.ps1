[CmdletBinding()]
param(
  [string]$PragmaPath = (Join-Path $env:USERPROFILE "Pragma\pragma"),
  [string]$PragmaHome = (Join-Path $env:USERPROFILE ".pragma"),
  [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$resolvedPragmaPath = (Resolve-Path -LiteralPath $PragmaPath).Path
$bundlePath = Join-Path $scriptRoot "..\assets\bundles\agency-agents-all.pragma"
$env:PRAGMA_HOME = [IO.Path]::GetFullPath($PragmaHome)
$env:PRAGMA_SOURCE_ROOT = $resolvedPragmaPath
$env:PRAGMA_AGENCY_BUNDLE = [IO.Path]::GetFullPath($bundlePath)
$env:PRAGMA_AGENCY_MODE = "verify"
$helper = Join-Path $scriptRoot "bootstrap_pragma_agency.ts"
Push-Location (Join-Path $resolvedPragmaPath "examples")
try {
  & corepack pnpm@10.12.1 exec tsx $helper
  $exitCode = $LASTEXITCODE
} finally { Pop-Location }
if ($exitCode -ne 0) { throw "Pragma verification failed with exit code $exitCode" }
