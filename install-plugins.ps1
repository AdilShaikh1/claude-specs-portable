<#
  Install the plugins enabled in settings.json via the Claude Code CLI.

  IMPORTANT: `enabledPlugins` in settings.json only ENABLES plugins already installed
  locally — it does NOT download/install them. This script does the actual install.
  Run it once on a new machine AFTER `claude` + /login, then reload your window.

  Usage:  ./install-plugins.ps1 [-DryRun]
#>
param([switch]$DryRun)
$ErrorActionPreference = 'Stop'

$Dst = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$Settings = Join-Path $Dst 'settings.json'
if (-not (Test-Path $Settings)) { Write-Error "No settings.json at $Settings — run install.ps1 first."; exit 1 }
if (-not $DryRun -and -not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Error "claude CLI not on PATH. Open Claude Code once (or add it to PATH), then re-run."; exit 1
}

$cfg = Get-Content $Settings -Raw | ConvertFrom-Json
$plugins = @()
if ($cfg.PSObject.Properties.Name -contains 'enabledPlugins' -and $cfg.enabledPlugins) {
  $plugins = $cfg.enabledPlugins.PSObject.Properties | Where-Object { $_.Value -eq $true } | ForEach-Object { $_.Name }
}
if (-not $plugins) { Write-Host "No enabled plugins in $Settings — nothing to install."; exit 0 }

function Get-MarketplaceRepo($mp) {
  if ($mp -eq 'claude-plugins-official') { 'anthropics/claude-plugins-official' } else { '' }
}

Write-Host "Registering marketplaces..."
$plugins | ForEach-Object { ($_ -split '@')[-1] } | Sort-Object -Unique | ForEach-Object {
  $repo = Get-MarketplaceRepo $_
  if ($repo) {
    if ($DryRun) { Write-Host "  DRY: claude plugin marketplace add $repo" }
    else { Write-Host "  + marketplace add $repo"; claude plugin marketplace add $repo }
  } else {
    Write-Host "  NOTE: marketplace '$_' has no known repo — register it yourself:"
    Write-Host "        claude plugin marketplace add <owner/repo>"
  }
}

Write-Host "Installing $($plugins.Count) plugin(s)..."
foreach ($p in $plugins) {
  if ($DryRun) { Write-Host "  DRY: claude plugin install $p --scope user"; continue }
  Write-Host "  installing $p"
  try { claude plugin install $p --scope user }
  catch { Write-Warning "FAILED: $p  (logged in? run 'claude' then /login, then re-run this script)" }
}

if ($DryRun) { Write-Host "(dry run — nothing changed)" }
else { Write-Host "Done. Reload your window (VS Code: 'Developer: Reload Window') so the plugins load." }
