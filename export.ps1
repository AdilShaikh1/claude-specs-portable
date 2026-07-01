<#
  (Re)package this bundle into claude-config-bundle.zip.
  Usage:  ./export.ps1 [-Refresh]
    -Refresh   first re-pull the verbatim parts (skills, blocklist, .ps1 helpers,
               VPE memory, keybindings) from this machine's live config dir.

  The three hand-authored files are intentionally NOT regenerated:
    settings.json (templated), hooks\claude-notify-hook.py (OS-detecting), memory\CLAUDE.md
#>
param([switch]$Refresh)
$ErrorActionPreference = 'Stop'

$Bundle = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcCfg = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }

if ($Refresh) {
  Write-Host "Refreshing verbatim parts from $SrcCfg ..."
  if (Test-Path "$SrcCfg\skills") {
    Remove-Item "$Bundle\skills" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item "$SrcCfg\skills" "$Bundle\skills" -Recurse -Force
  }
  if (Test-Path "$SrcCfg\plugins\blocklist.json") { Copy-Item "$SrcCfg\plugins\blocklist.json" "$Bundle\plugins\blocklist.json" -Force }
  foreach ($f in 'claude-notify.ps1','set-audio-output.ps1') {
    if (Test-Path "$SrcCfg\hooks\$f") { Copy-Item "$SrcCfg\hooks\$f" "$Bundle\hooks\$f" -Force }
  }
  $key = ($env:USERPROFILE -replace '[:\\/]','-')
  $memDir = Join-Path $SrcCfg "projects\$key\memory"
  if (Test-Path $memDir) {
    Remove-Item "$Bundle\memory\vpe\*.md" -Force -ErrorAction SilentlyContinue
    Copy-Item "$memDir\*.md" "$Bundle\memory\vpe\" -Force
    Write-Host "Refreshed VPE memory snapshot from $memDir"
  }
  if (Test-Path "$SrcCfg\keybindings.json") { Copy-Item "$SrcCfg\keybindings.json" "$Bundle\keybindings.json" -Force }
  Write-Host "NOTE: settings.json, hooks\claude-notify-hook.py, memory\CLAUDE.md are hand-maintained (left as-is)."
}

$out = Join-Path $Bundle 'claude-config-bundle.zip'
if (Test-Path $out) { Remove-Item $out -Force }
$items = Get-ChildItem -Path $Bundle -Exclude '*.zip','*.tar.gz','*.bak-*','.testinstall','.verify'
Compress-Archive -Path $items.FullName -DestinationPath $out -Force
Write-Host "Wrote $out"