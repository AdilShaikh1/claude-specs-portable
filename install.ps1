<#
  Install the portable Claude Code config into this machine's %USERPROFILE%\.claude.
  Usage:  ./install.ps1 [-WithVpe] [-SetAudio]
    -WithVpe    also restore the VPE-specific project memory (memory/vpe/)
    -SetAudio   set the default Windows playback device (runs set-audio-output.ps1)

  Secrets are NEVER touched: log in separately after install (claude, then /login).
#>
param([switch]$WithVpe, [switch]$SetAudio)
$ErrorActionPreference = 'Stop'

$Src = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dst = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }

Write-Host "Source bundle : $Src"
Write-Host "Target config : $Dst"
foreach ($d in 'hooks','skills','plugins') { New-Item -ItemType Directory -Force -Path (Join-Path $Dst $d) | Out-Null }

# 1. Hooks, skills, plugin blocklist (verbatim) -----------------------------
Copy-Item "$Src\hooks\*" (Join-Path $Dst 'hooks') -Force
Copy-Item "$Src\skills\*" (Join-Path $Dst 'skills') -Recurse -Force
Copy-Item "$Src\plugins\blocklist.json" (Join-Path $Dst 'plugins\blocklist.json') -Force

# 2. settings.json (template -> real paths). Forward slashes keep JSON valid. -
$py = if (Get-Command python -ErrorAction SilentlyContinue) { 'python' } else { 'python3' }
$hooksDir = ((Join-Path $Dst 'hooks') -replace '\\','/')
$settingsDst = Join-Path $Dst 'settings.json'
if (Test-Path $settingsDst) {
  for ($n=1; $n -le 9; $n++) {
    $bak = "$settingsDst.bak-$n"
    if (-not (Test-Path $bak)) { Copy-Item $settingsDst $bak; Write-Host "Backed up existing settings -> settings.json.bak-$n"; break }
  }
}
(Get-Content "$Src\settings.json" -Raw).Replace('__PY__', $py).Replace('__HOOKS_DIR__', $hooksDir) |
  Set-Content $settingsDst -NoNewline

# 3. Optional keybindings ----------------------------------------------------
if (Test-Path "$Src\keybindings.json") { Copy-Item "$Src\keybindings.json" (Join-Path $Dst 'keybindings.json') -Force }

# 4. Global memory: transferable rules -> CLAUDE.md --------------------------
Copy-Item "$Src\memory\CLAUDE.md" (Join-Path $Dst 'CLAUDE.md') -Force
Write-Host "Installed global rules -> $(Join-Path $Dst 'CLAUDE.md')"

# 5. Optional VPE project memory --------------------------------------------
if ($WithVpe) {
  $key = ($env:USERPROFILE -replace '[:\\/]','-')   # C:\Users\bob -> C--Users-bob
  $mem = Join-Path $Dst "projects\$key\memory"
  New-Item -ItemType Directory -Force -Path $mem | Out-Null
  Copy-Item "$Src\memory\vpe\*.md" $mem -Force
  Write-Host "Installed VPE project memory -> $mem"
  Write-Host "  (verify this key matches the dir you run 'claude' from; move it if not)"
}

# Optional: set the default Windows playback device --------------------------
if ($SetAudio) {
  Write-Host "Setting default Windows playback device..."
  try { powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Dst 'hooks\set-audio-output.ps1') }
  catch { Write-Warning "set-audio failed: $_" }
}

Write-Host ""
Write-Host "Done. Next steps on this machine:"
Write-Host "  1. Run:  claude"
Write-Host "  2. Log in:  /login           (OAuth/account is per-machine, not bundled)"
Write-Host "  3. Re-auth MCP connectors:  /mcp"
Write-Host "  4. Plugins re-download on first run (official marketplace is always available)."
Write-Host "  5. Trigger a Stop event to confirm the notification hook fires."