#!/bin/bash
# Juniper ZTP Setup Script
# Platform: Geekom A5 (or any Debian-based x86 machine)
# Tested on Ubuntu 24.04 LTS

set -e

echo "Installing required packages..."
sudo apt install -y vsftpd kea-dhcp4-server

echo "Creating FTP directory structure..."
sudo mkdir -p /srv/ftp/code/EX2300
sudo mkdir -p /srv/ftp/code/EX3400
sudo mkdir -p /srv/ftp/code/EX4100
sudo mkdir -p /srv/ftp/code/EX4600
sudo mkdir -p /srv/ftp/code/EX4650
sudo mkdir -p /srv/ftp/code/MX204
sudo mkdir -p /srv/ftp/code/SRX300
sudo mkdir -p /srv/ftp/slax
sudo mkdir -p /srv/ftp/config

echo "Copying config files..."
sudo cp setup/vsftpd.conf /etc/vsftpd.conf
sudo cp setup/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf
sudo cp configs/access.conf /srv/ftp/config/
sudo cp slax/ztp.slax /srv/ftp/slax/

echo "Setting permissions..."
sudo chmod 755 /srv/ftp/code
sudo chmod 755 /srv/ftp/slax
sudo chmod 755 /srv/ftp/config
sudo chmod -R 755 /srv/ftp/code/*

echo "Restarting services..."
sudo systemctl restart vsftpd
sudo systemctl restart kea-dhcp4-server

echo ""
echo "Setup complete! Don't forget to:"
echo "  1. Place your Junos image(s) in the correct /srv/ftp/code/<MODEL>/ directory"
echo "  2. Update target versions in slax/ztp.slax to match your images"
echo "  3. Update passwords in /srv/ftp/config/access.conf"
echo "  4. If using aggcore devices (EX4600/QFX), create /srv/ftp/config/aggcore.conf"
