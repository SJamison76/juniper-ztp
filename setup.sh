#!/bin/bash
# Juniper ZTP Setup Script

echo "Installing required packages..."
sudo apt install -y vsftpd isc-dhcp-server

echo "Creating FTP directory structure..."
sudo mkdir -p /srv/ftp/code
sudo mkdir -p /srv/ftp/slax
sudo mkdir -p /srv/ftp/config

echo "Copying config files..."
sudo cp setup/vsftpd.conf /etc/vsftpd.conf
sudo cp setup/dhcpd.conf /etc/dhcp/dhcpd.conf
sudo cp configs/access.conf /srv/ftp/config/
sudo cp slax/ztp.slax /srv/ftp/slax/

echo "Setting permissions..."
sudo chmod 755 /srv/ftp/code
sudo chmod 755 /srv/ftp/slax
sudo chmod 755 /srv/ftp/config

echo "Configuring isc-dhcp-server interface..."
sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server

echo "Restarting services..."
sudo systemctl restart vsftpd
sudo systemctl restart isc-dhcp-server

echo ""
echo "Setup complete! Don't forget to:"
echo "  1. Place your Junos image in /srv/ftp/code/"
echo "  2. Update passwords in /srv/ftp/config/access.conf"
echo "  3. Update IP addresses in /etc/dhcp/dhcpd.conf if needed"
