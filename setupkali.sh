#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Update Kali
apt update -y

# Upgrade Kali
apt full-upgrade -y

# Install metapackage
apt install -y kali-linux-default

echo "Setup completed."
