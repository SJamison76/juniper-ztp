# Juniper ZTP (Zero Touch Provisioning)

Automated provisioning system for Juniper EX2300, EX3400, and EX4600 switches using a Raspberry Pi.

## Requirements

- Raspberry Pi running Raspberry Pi OS (Debian-based)
- Network interface connected to switch management network
- Junos image files (downloaded separately from Juniper support portal)

## Supported Devices

| Model | Junos Image Format |
|-------|-------------------|
| EX2300 | junos-arm-32-[version].tgz |
| EX3400 | junos-arm-32-[version].tgz |
| EX4600 | jinstall-host-ex-4600-[version]-signed.tgz |

## Setup

1. Clone this repository:
git clone https://github.com/SJamison76/juniper-ztp.git
cd juniper-ztp

2. Run the setup script:
chmod +x setup.sh
./setup.sh

3. Download the required Junos image(s) from Juniper support portal and place in `/srv/ftp/code/`

4. Update target versions in `slax/ztp.slax`:

Examples:
param $ex2300 = "24.4R2-S4.10";
param $ex3400 = "18.2R3-S2.9";
param $ex4600 = "18.3R2.7";

5. Update IP addresses in `setup/dhcpd.conf` to match your network

6. Update passwords in `configs/access.conf`

## FTP Directory Structure

/srv/ftp/
├── code/        # Junos image files
├── slax/        # ZTP SLAX script
└── config/      # Device config files

## How It Works

1. Switch boots and sends DHCP request
2. DHCP server identifies device type via vendor class and hands out ZTP options
3. Switch downloads and applies `config/access.conf`
4. Event policy runs the SLAX script every 5 minutes
5. SLAX script checks current Junos version, downloads and installs target version if needed
6. Switch reboots into new image
