[CmdletBinding()]
param(
  [string]$PragmaPath,
  [switch]$NoNewWindow,
  [switch]$SkipDependencyInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$pnpmShimScript = Join-Path $scriptRoot "ensure_pnpm_shim.ps1"
& $pnpmShimScript | Out-Null
$pnpmShimRoot = Join-Path $env:LOCALAPPDATA "lvsea-pragma-agency\bin"
$env:Path = "$pnpmShimRoot;$env:Path"

function Resolve-PragmaSource {
  param([string]$RequestedPath)
  $candidates = @()
  if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) { $candidates += $RequestedPath }
  if (-not [string]::IsNullOrWhiteSpace($env:PRAGMA_SOURCE_ROOT)) { $candidates += $env:PRAGMA_SOURCE_ROOT }
  $candidates += (Join-Path $env:USERPROFILE "Pragma\pragma")
  foreach ($candidate in $candidates) {
    if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path -LiteralPath $candidate -PathType Container) -and (Test-Path -LiteralPath (Join-Path $candidate "package.json") -PathType Leaf)) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }
  throw "Pragma source not found. Install with install_pragma_agency.ps1 or pass -PragmaPath."
}

$resolvedPragmaPath = Resolve-PragmaSource $PragmaPath
$packageJson = Get-Content -LiteralPath (Join-Path $resolvedPragmaPath "package.json") -Raw -Encoding utf8 | ConvertFrom-Json
$node = Get-Command node -ErrorAction SilentlyContinue
if ($null -eq $node) { throw "Node.js is required to start Pragma." }
$nodeVersion = (& node --version).Trim().TrimStart("v")
$major = [int]($nodeVersion.Split('.')[0])
if ($major -lt 22) { throw "Pragma requires Node.js >=22; found $nodeVersion." }

if (-not $SkipDependencyInstall -and -not (Test-Path -LiteralPath (Join-Path $resolvedPragmaPath "node_modules") -PathType Container)) {
  Push-Location $resolvedPragmaPath
  try { & corepack pnpm@10.12.1 install --frozen-lockfile } finally { Pop-Location }
}

$command = "`$env:Path = '$pnpmShimRoot;' + `$env:Path; Set-Location -LiteralPath '$resolvedPragmaPath'; corepack pnpm@10.12.1 --filter @pragma/desktop dev"
if ($NoNewWindow) {
  Write-Output "Starting Pragma from $resolvedPragmaPath"
  Invoke-Expression $command
  exit $LASTEXITCODE
}

Start-Process -FilePath "powershell.exe" -WindowStyle Normal -ArgumentList @(
  "-NoProfile",
  "-ExecutionPolicy", "Bypass",
  "-NoExit",
  "-Command", $command
)
Write-Output "Pragma start window launched: $resolvedPragmaPath"
