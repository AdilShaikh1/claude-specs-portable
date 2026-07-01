param(
    [string]$Title   = "Claude Code",
    [string]$Message = "",
    [string]$Sound   = ""
)

# --- On-screen toast (tray balloon -> Action Center on Win10/11). No external modules needed. ---
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $icon = New-Object System.Windows.Forms.NotifyIcon
    $icon.Icon            = [System.Drawing.SystemIcons]::Information
    $icon.BalloonTipTitle = $Title
    $icon.BalloonTipText  = $Message
    $icon.Visible         = $true
    $icon.ShowBalloonTip(6000)   # non-blocking; lives as long as the process does
} catch { }

# --- Sound (blocking PlaySync also keeps the process alive so the toast renders) ---
try {
    if ($Sound -and (Test-Path $Sound)) {
        (New-Object Media.SoundPlayer $Sound).PlaySync()
    }
} catch { }

Start-Sleep -Milliseconds 800
try { if ($icon) { $icon.Dispose() } } catch { }