[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory = $true)]
  [string]$BackupPath,
  [string]$PragmaHome = (Join-Path $env:USERPROFILE ".pragma")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$backup = (Resolve-Path -LiteralPath $BackupPath).Path
if (-not (Test-Path -LiteralPath (Join-Path $backup "backup-manifest.json") -PathType Leaf)) {
  throw "Refusing rollback: backup-manifest.json is missing from $backup"
}
$manifest = Get-Content -LiteralPath (Join-Path $backup "backup-manifest.json") -Raw -Encoding utf8 | ConvertFrom-Json
if ($manifest.kind -notin @("lvsea-zhuanjia-backup", "lvsea-pragma-agency-backup", "qiaomu-pragma-agency-backup")) { throw "Refusing rollback: unsupported backup kind." }
if ($manifest.pragmaHome -ne [IO.Path]::GetFullPath($PragmaHome)) {
  throw "Refusing rollback: backup belongs to $($manifest.pragmaHome), not $PragmaHome"
}
if ($PSCmdlet.ShouldProcess($PragmaHome, "restore Pragma data from explicit backup $backup")) {
  if (Test-Path -LiteralPath $PragmaHome) {
    $liveBackup = "$PragmaHome.before-rollback-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -LiteralPath $PragmaHome -Destination $liveBackup
    Write-Output "Current data moved to: $liveBackup"
  }
  Copy-Item -LiteralPath (Join-Path $backup "pragma") -Destination $PragmaHome -Recurse -Force
  Write-Output "Rollback restored: $PragmaHome"
}
