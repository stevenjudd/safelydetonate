#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Update Kali
apt update -y

# Install Win-Kex (this is over 1GB)
apt install kali-win-kex

echo ""
echo "=================="
echo "run 'kex --win -s'"
echo "=================="
