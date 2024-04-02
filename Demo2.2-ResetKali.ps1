function Write-sjCommandText {
  param (
    [string]$PreCommand,
    [string]$Command,
    [string]$PostCommand
  )
  
  $commandLength = $PreCommand.Length + $Command.Length + $PostCommand.Length + 2
  Write-Host ("$([char]0x2193)" * $commandLength) -ForegroundColor Yellow
  Write-Host "$PreCommand " -ForegroundColor Cyan -NoNewline
  Write-Host "$Command " -ForegroundColor Magenta -NoNewline
  Write-Host "$PostCommand" -ForegroundColor Cyan
  Write-Host ("$([char]0x2191)" * $commandLength) -ForegroundColor Yellow
}

# reset a Kali-linux image
Write-Host 'Resetting Kali-linux image...' -ForegroundColor Yellow
wsl --unregister kali-linux

$writeSjCommandText = @{
  'PreCommand' = 'Installing kali-linux image. Type'
  'Command' = 'exit'
  'PostCommand' = 'and press Enter when at the prompt'
}
Write-sjCommandText @writeSjCommandText
wsl --install -d kali-linux

# Copy setup script
wsl -d kali-linux cp /mnt/c/Users/steve/git/github/stevenjudd/safelydetonate/setupkali.sh /home/steve/setupkali.sh

# Run Kali Linux and run setup script
$writeSjCommandText = @{
  'PreCommand' = 'Run script:'
  'Command' = './setupkali.sh'
  'PostCommand' = 'as root'
}
Write-sjCommandText @writeSjCommandText

wsl -d kali-linux
#endregion Setp 4

#region Step 5
# Copy setup script
wsl -d kali-linux cp /mnt/c/Users/steve/git/github/stevenjudd/safelydetonate/setupwinkex.sh /home/steve/setupkali.sh

# Run Kali Linux and run Win-Kex script
$writeSjCommandText = @{
  'PreCommand' = 'Run script:'
  'Command' = './setupwinkex.sh'
  'PostCommand' = 'as root'
}
Write-sjCommandText @writeSjCommandText

wsl -d kali-linux
