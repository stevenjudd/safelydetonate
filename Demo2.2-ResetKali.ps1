# reset a Kali-linux image
wsl --unregister kali-linux
wsl --install -d kali-linux

# Copy setup script
wsl -d kali-linux cp /mnt/c/Users/steve/OneDrive/Documents/Presentations/SafelyDetonate/setupkali.sh /home/steve/setupkali.sh

# Run Kali Linux and run setup script
Write-Host 'Run ./setuplinux.sh script' -ForegroundColor Cyan
wsl -d kali-linux
