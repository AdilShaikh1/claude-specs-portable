# Sets the default Windows playback device to Jabra (if connected), else Realtek.
# Installs AudioDeviceCmdlets (CurrentUser, no admin) on first run.
# Re-run any time to re-assert the output device.
$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name AudioDeviceCmdlets)) {
    Write-Host "Installing AudioDeviceCmdlets (CurrentUser)..."
    try { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null } catch { }
    try { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted } catch { }
    Install-Module -Name AudioDeviceCmdlets -Scope CurrentUser -Force -AllowClobber
}
Import-Module AudioDeviceCmdlets

$playback = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }

$target = $playback | Where-Object { $_.Name -match 'Jabra' } | Select-Object -First 1
if (-not $target) {
    $target = $playback | Where-Object { $_.Name -match 'Realtek' } | Select-Object -First 1
}

if ($target) {
    Set-AudioDevice -ID $target.ID | Out-Null
    "Default playback device set to: $($target.Name)"
} else {
    Write-Warning "No Jabra or Realtek playback device found. Available playback devices:"
    $playback | ForEach-Object { "  - $($_.Name)" }
}