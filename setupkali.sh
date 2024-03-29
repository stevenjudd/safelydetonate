#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Update Kali
apt update -y

# Install XFCE
apt install -y xfce4

# Install XRDP
apt install -y xrdp

# Start XRDP
/etc/init.d/xrdp start

# Change XRDP port if 3389 is in use, check and change the correct file
if grep -q 'port=3389' /etc/xrdp/xrdp.ini; then
    sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
    # restart XRDP to apply the change
    /etc/init.d/xrdp restart
fi

echo "Setup completed."
