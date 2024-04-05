# Import WSL2 images
# https://www.virtualizationhowto.com/2021/01/wsl2-backup-and-restore-images-using-import-and-export/

# Import the image
wsl --import kali-linux C:\Users\steve\AppData\Local\Packages\CustomKali $env:TEMP\kali-linux.tar

# List available distributions
wsl --list