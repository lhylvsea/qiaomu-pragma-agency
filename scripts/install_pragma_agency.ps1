[CmdletBinding()]
param(
  [string]$PragmaPath = (Join-Path $env:USERPROFILE "Pragma\pragma"),
  [string]$PragmaHome = (Join-Path $env:USERPROFILE ".pragma"),
  [ValidateSet("all", "manufacturing")]
  [string]$Bundle = "all",
  [switch]$IncludeManufacturingTeam,
  [switch]$SkipDependencyInstall,
  [switch]$SkipShortcut,
  [switch]$SkipStart
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$packageRoot = (Resolve-Path -LiteralPath (Join-Path $scriptRoot "..")).Path
$pnpmShimScript = Join-Path $scriptRoot "ensure_pnpm_shim.ps1"
& $pnpmShimScript | Out-Null
$pnpmShimRoot = Join-Path $env:LOCALAPPDATA "qiaomu-pragma-agency\bin"
$env:Path = "$pnpmShimRoot;$env:Path"
$bundlePath = Join-Path $packageRoot "assets\bundles\agency-agents-all.pragma"
if ($Bundle -eq "manufacturing") { $bundlePath = Join-Path $packageRoot "assets\bundles\manufacturing-operations-team.pragma" }
if (-not (Test-Path -LiteralPath $bundlePath -PathType Leaf)) { throw "Embedded Bundle not found: $bundlePath" }

function Invoke-Checked {
  param([string]$FilePath, [string[]]$ArgumentList)
  & $FilePath @ArgumentList
  if ($LASTEXITCODE -ne 0) { throw "$FilePath failed with exit code $LASTEXITCODE" }
}

$git = Get-Command git -ErrorAction SilentlyContinue
if ($null -eq $git) { throw "Git is required to obtain pqpo/pragma." }
$node = Get-Command node -ErrorAction SilentlyContinue
if ($null -eq $node) { throw "Node.js >=22 is required." }
$nodeVersion = (& node --version).Trim().TrimStart("v")
if ([int]($nodeVersion.Split('.')[0]) -lt 22) { throw "Pragma requires Node.js >=22; found $nodeVersion." }

if (-not (Test-Path -LiteralPath $PragmaPath -PathType Container)) {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PragmaPath) | Out-Null
  Invoke-Checked "git" @("clone", "https://github.com/pqpo/pragma.git", $PragmaPath)
} elseif (-not (Test-Path -LiteralPath (Join-Path $PragmaPath ".git") -PathType Container)) {
  throw "PragmaPath exists but is not a Git checkout: $PragmaPath"
}
$PragmaPath = (Resolve-Path -LiteralPath $PragmaPath).Path

if (-not $SkipDependencyInstall -and -not (Test-Path -LiteralPath (Join-Path $PragmaPath "node_modules") -PathType Container)) {
  Push-Location $PragmaPath
  try { Invoke-Checked "corepack" @("pnpm@10.12.1", "install", "--frozen-lockfile") } finally { Pop-Location }
}

& (Join-Path $scriptRoot "apply_pragma_patch.ps1") -PragmaPath $PragmaPath

$backupRoot = Join-Path (Split-Path -Parent $PragmaHome) "pragma-agency-backups"
$backupPath = Join-Path $backupRoot (Get-Date -Format "yyyyMMdd-HHmmss")
New-Item -ItemType Directory -Force -Path $backupPath | Out-Null
if (Test-Path -LiteralPath $PragmaHome -PathType Container) {
  Copy-Item -LiteralPath $PragmaHome -Destination (Join-Path $backupPath "pragma") -Recurse -Force
} else {
  New-Item -ItemType Directory -Force -Path (Join-Path $backupPath "pragma") | Out-Null
}
$backupManifest = [ordered]@{
  kind = "qiaomu-pragma-agency-backup"
  createdAt = (Get-Date).ToUniversalTime().ToString("o")
  pragmaHome = [IO.Path]::GetFullPath($PragmaHome)
  pragmaSource = $PragmaPath
  bundle = $bundlePath
}
[IO.File]::WriteAllText((Join-Path $backupPath "backup-manifest.json"), ($backupManifest | ConvertTo-Json -Depth 4) + "`n", [Text.UTF8Encoding]::new($false))

$env:PRAGMA_HOME = [IO.Path]::GetFullPath($PragmaHome)
$env:PRAGMA_SOURCE_ROOT = $PragmaPath
$env:PRAGMA_AGENCY_BUNDLE = [IO.Path]::GetFullPath($bundlePath)
$env:PRAGMA_AGENCY_MODE = "install"
$helper = Join-Path $scriptRoot "bootstrap_pragma_agency.ts"
Push-Location (Join-Path $PragmaPath "examples")
try { Invoke-Checked "corepack" @("pnpm@10.12.1", "exec", "tsx", $helper) } finally { Pop-Location }

if ($IncludeManufacturingTeam -and $Bundle -eq "all") {
  $env:PRAGMA_AGENCY_BUNDLE = [IO.Path]::GetFullPath((Join-Path $packageRoot "assets\bundles\manufacturing-operations-team.pragma"))
  Push-Location (Join-Path $PragmaPath "examples")
  try { Invoke-Checked "corepack" @("pnpm@10.12.1", "exec", "tsx", $helper) } finally { Pop-Location }
}

if (-not $SkipShortcut) {
  & (Join-Path $scriptRoot "create_pragma_shortcut.ps1") -PragmaPath $PragmaPath -StartScript (Join-Path $scriptRoot "start_pragma.ps1")
}
& (Join-Path $scriptRoot "verify_pragma_agency.ps1") -PragmaPath $PragmaPath -PragmaHome $PragmaHome
if (-not $SkipStart) {
  & (Join-Path $scriptRoot "start_pragma.ps1") -PragmaPath $PragmaPath -SkipDependencyInstall
}
Write-Output "Backup: $backupPath"
Write-Output "Pragma source: $PragmaPath"
