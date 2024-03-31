# See https://www.linuxtechi.com/install-kali-linux-on-windows-wsl/

# Check for Admin
if ( -not(
  (New-Object Security.Principal.WindowsPrincipal (
      [Security.Principal.WindowsIdentity]::GetCurrent())
  ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))) {
  Write-Warning 'Must be run as administrator'
  return
}

# Install required Windows Features
#region Steps 1 and 2
$windowsFeatureList = @(
  'Microsoft-Windows-Subsystem-Linux'
  'VirtualMachinePlatform'
)
$installResult = Enable-WindowsOptionalFeature -Online -FeatureName $WindowsFeatureList -All -NoRestart
if ($installResult.RestartNeeded) {
  Write-Host 'The installation of Windows Features requires a reboot'
  $null = Read-Host 'Press Enter to reboot or Ctrl+C to cancel'
  Restart-Computer
}

# code to fix utf-16 issue from https://github.com/PowerShell/PowerShell/pull/21219
$origEncoding = [Console]::OutputEncoding
try {
  [Console]::OutputEncoding = [System.Text.Encoding]::Unicode
  $wslVersion = wsl --version
  $wslList = wsl --list
} finally {
  [Console]::OutputEncoding = $origEncoding
}

# Set WSL2 as default
$wslMajorVersion = ($wslVersion |
    Select-String -Pattern 'wsl version: (\d)').Matches.Groups.Where({ $_.Name -eq 1 }).Value
Wait-Debugger
if ($wslMajorVersion -ne 2) {
  wsl --set-default-version 2
}
#endregion Steps 1 and 2

# Step 3 is not needed if installing fresh per:
# https://learn.microsoft.com/en-us/windows/wsl/install#upgrade-version-from-wsl-1-to-wsl-2

# Install Kali Linux
#region Step 4
if ($wslList -match 'kali-linux') {
  # already installed
} else {
  wsl --install -d kali-linux
}
#endregion Step 4

#region extra setup
# Copy setup script
wsl -d kali-linux cp /mnt/c/Users/steve/OneDrive/Documents/Presentations/SafelyDetonate/setupkali.sh /home/steve/setupkali.sh

# Run Kali Linux and run setup script
Write-Host ("$([char]0x2193)" * 27) -ForegroundColor Yellow
Write-Host 'Run script: ' -ForegroundColor Cyan -NoNewline
Write-Host './setuplinux.sh' -ForegroundColor Magenta
Write-Host ("$([char]0x2191)" * 27) -ForegroundColor Yellow

wsl -d kali-linux
#endregion Setp 4

#region Step 5
# Run Kali Linux and run Win-Kex script
Write-Host ("$([char]0x2193)" * 27) -ForegroundColor Yellow
Write-Host 'Run script: ' -ForegroundColor Cyan -NoNewline
Write-Host './setupwinkex.sh' -ForegroundColor Magenta
Write-Host ("$([char]0x2191)" * 27) -ForegroundColor Yellow

# Run Kali using Win-Kex
wsl -d kali-linux kex --win -s
