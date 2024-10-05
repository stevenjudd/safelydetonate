# Export WSL2 images
# https://www.virtualizationhowto.com/2021/01/wsl2-backup-and-restore-images-using-import-and-export/

# This will stop all kali-linux images and Docker may complain
wsl -d kali-linux --shutdown

# Make a backup image
wsl --export kali-linux $env:TEMP\kali-linux.tar
Get-ChildItem $env:TEMP\kali-linux.tar
(Get-ChildItem $env:TEMP\kali-linux.tar).Length / 1GB
