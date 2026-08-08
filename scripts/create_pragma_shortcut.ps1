[CmdletBinding()]
param(
  [string]$PragmaPath,
  [string]$StartScript,
  [string]$ShortcutPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($StartScript)) {
  $StartScript = Join-Path $PSScriptRoot "start_pragma.ps1"
}
if (-not (Test-Path -LiteralPath $StartScript -PathType Leaf)) { throw "Start script not found: $StartScript" }
if ([string]::IsNullOrWhiteSpace($ShortcutPath)) {
  $ShortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Pragma - Agency Agents.lnk"
}
$shortcutDirectory = Split-Path -Parent $ShortcutPath
New-Item -ItemType Directory -Force -Path $shortcutDirectory | Out-Null

$escapedStart = $StartScript.Replace('"', '""')
$arguments = "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$escapedStart`""
if (-not [string]::IsNullOrWhiteSpace($PragmaPath)) {
  $escapedPragma = $PragmaPath.Replace('"', '""')
  $arguments += " -PragmaPath `"$escapedPragma`""
}
$arguments += " -NoNewWindow"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = (Get-Command powershell.exe).Source
$shortcut.Arguments = $arguments
$shortcut.WorkingDirectory = Split-Path -Parent $StartScript
$shortcut.Description = "Start Pragma with the Agency Agents expert bundle"
$shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,16"
$shortcut.Save()

$check = $shell.CreateShortcut($ShortcutPath)
if ($check.TargetPath -ne (Get-Command powershell.exe).Source -or -not $check.Arguments.Contains("start_pragma.ps1")) {
  throw "Shortcut verification failed: $ShortcutPath"
}
Write-Output "Shortcut: $ShortcutPath"
Write-Output "Target: $($check.TargetPath) $($check.Arguments)"
