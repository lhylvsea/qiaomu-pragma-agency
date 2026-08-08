[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$PragmaPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedPragmaPath = (Resolve-Path -LiteralPath $PragmaPath).Path
$target = Join-Path $resolvedPragmaPath "apps\desktop\src\main\platform\bindings\desktop-bound-resource-policy.ts"
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
  throw "Pragma binding policy was not found: $target"
}

$content = [IO.File]::ReadAllText($target)
if ($content.Contains("config: { key: binding.id },")) {
  Write-Output "Pragma binding patch: already applied ($target)"
  exit 0
}

$old = "      config: { ...(resource.spec.config ?? {}), key: binding.id },"
$new = @"
      // Portable/imported capability configs can contain source-local keys such as
      // `source` and `entry`. The host adapter accepts only its local lookup key.
      config: { key: binding.id },
"@
if (-not $content.Contains($old)) {
  throw "Unsupported Pragma binding policy; refusing an unreviewed source rewrite: $target"
}

$backup = "$target.qiaomu-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item -LiteralPath $target -Destination $backup -Force
$updated = $content.Replace($old, $new.TrimEnd("`r", "`n"))
[IO.File]::WriteAllText($target, $updated, [Text.UTF8Encoding]::new($false))
Write-Output "Pragma binding patch: applied"
Write-Output "Source backup: $backup"
