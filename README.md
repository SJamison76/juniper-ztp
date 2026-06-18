# Juniper ZTP (Zero Touch Provisioning)

ZTP v5.0.3 - fully working end-to-end pipeline

Tested on EX2300-C-12P, 21.4R3-S10.13 -> 23.2R2-S7.5

Working flow:
- Factory boot -> DHCP -> access.conf -> event policy
- ztp.slax detects model/version, downloads image to /var/tmp/
- Installs with --unlink --reboot, reboots into target version
- Takes recovery + non-recovery snapshots
- Removes event-options, cleans interfaces, sets hostname staging-complete

Key fixes from previous versions:
- Replaced all jcs:open()/jcs:execute() with jcs:invoke() - required
  for event-options execute-commands context on JunOS 21.4
- Added xnm-clear-text to access.conf for Junos XML protocol server
- EX2300 local /var/tmp/ path fix (no model subdir prefix)
- Serial number via shell grep instead of broken token split
- Removed 'request system storage cleanup' from rm-rundb (kills
  script's own /var/tmp/tmp_op* execution directory)
- Removed schema.db/render.db deletion (crashes pfed/commitd mid-run)
- Final config via CLI pipe instead of load-configuration RPC
- Shell output parsing via normalize-space(string($res)) not $res//output
- Added shebang line #!/usr/libexec/ui/cscript

Known minor issues:
- Serial number still parsing empty (cosmetic, doesn't affect function)
- ztp:end-script() harmless SLAX error when called inside func:function

Automated provisioning system for Juniper EX2300, EX3400, EX4100, EX4600, EX4650, MX204, and SRX300 devices using a Raspberry Pi.

## Requirements

- Raspberry Pi running Raspberry Pi OS (Debian-based)
- Network interface (`eth0`) connected to switch management network
- Junos image files (downloaded separately from Juniper support portal)

## Supported Devices

| Model | Junos Image Format |
|-------|-------------------|
| EX2300 | junos-arm-32-[version].tgz |
| EX3400 | junos-arm-32-[version].tgz |
| EX4100 | junos-install-ex-arm-64-[version].tgz |
| EX4600 | jinstall-host-ex-4600-[version]-signed.tgz |
| EX4650 | jinstall-host-ex-4e-x86-64-[version]-secure-signed.tgz |
| MX204  | junos-vmhost-install-mx-x86-64-[version].tgz |
| SRX300 | junos-srxsme-[version].tgz |

## Setup

1. Clone this repository:
   ```
   git clone https://github.com/SJamison76/juniper-ztp.git
   cd juniper-ztp
   ```

2. Run the setup script:
   ```
   chmod +x setup.sh
   ./setup.sh
   ```

3. Download the required Junos image(s) from the Juniper support portal and place them in the correct model subdirectory:
   ```
   /srv/ftp/code/EX2300/junos-arm-32-[version].tgz
   /srv/ftp/code/EX3400/junos-arm-32-[version].tgz
   /srv/ftp/code/EX4100/junos-install-ex-arm-64-[version].tgz
   /srv/ftp/code/EX4600/jinstall-host-ex-4600-[version]-signed.tgz
   /srv/ftp/code/EX4650/jinstall-host-ex-4e-x86-64-[version]-secure-signed.tgz
   /srv/ftp/code/MX204/junos-vmhost-install-mx-x86-64-[version].tgz
   /srv/ftp/code/SRX300/junos-srxsme-[version].tgz
   ```

4. Update target versions in `slax/ztp.slax` to match the images you placed in the FTP directories:
   ```
   param $ex2300 = "23.4R2-S8.7";
   param $ex3400 = "18.2R3-S2.9";
   param $ex4100 = "23.4R2-S8.7";
   param $ex4600 = "18.3R2.7";
   param $ex4650 = "23.4R2-S8.7";
   param $mx204  = "23.4R2-S8.7";
   param $srx300 = "23.4R2-S8.7";
   ```

5. Update IP addresses in `setup/dhcpd.conf` to match your network (default is `192.168.10.x/24`).

6. Update passwords in `configs/access.conf` (see Password section below).

## Default Credentials

The `configs/access.conf` file contains two default users:

| User  | Password  | Class       |
|-------|-----------|-------------|
| root  | Juniper   | superuser   |
| admin | Juniper   | FULL-ACCESS |

**These are pre-hashed SHA-512 encrypted passwords. You should replace them with your own.**

To generate a new encrypted password hash on any Juniper device:
```
request system set-encrypted-password
```

Then replace the `encrypted-password` strings in `configs/access.conf` with your own hashes. You can also add or remove users as needed.

## FTP Directory Structure

```
/srv/ftp/
├── code/
│   ├── EX2300/    # EX2300/EX2300-C images
│   ├── EX3400/    # EX3400 images
│   ├── EX4100/    # EX4100 images
│   ├── EX4600/    # EX4600 images
│   ├── EX4650/    # EX4650 images
│   ├── MX204/     # MX204 images
│   └── SRX300/    # SRX300 images
├── slax/
│   └── ztp.slax   # ZTP SLAX script
└── config/
    └── access.conf  # Bootstrap config pushed to device

Note: No uploads directory is needed - the ZTP script does not upload any files.
```

## How It Works

1. Switch boots with factory defaults and sends a DHCP request
2. DHCP server identifies the device type via vendor class identifier and hands out ZTP options
3. Switch downloads and applies `config/access.conf` via FTP
4. Event policy runs the SLAX script every 120 seconds
5. SLAX script identifies the device model, checks current Junos version against target
6. If upgrade/downgrade needed, script downloads the correct image from the model subdirectory and installs it
7. Switch reboots into new image
8. SLAX script runs again, confirms version is correct, takes snapshots, sets hostname to `staging-complete` and removes event policy

## Connecting the Switch

- During ZTP the switch uses `irb.0` or `vme.0` for DHCP — connect the Pi to any regular switch port (e.g. `ge-0/0/0`)
- Once `access.conf` is applied, the switch configures `me0` with DHCP for management access
- The SLAX script communicates via whichever interface has connectivity to `192.168.10.1`

## Notes

- The DHCP server must be running on the Pi (`sudo systemctl start isc-dhcp-server`)
- The FTP server must be running on the Pi (`sudo systemctl start vsftpd`)
- Directory names in `/srv/ftp/code/` must be UPPERCASE to match the model names returned by the SLAX script
- SNMP must be enabled on the device for the tracker functions to work — this is handled automatically by `access.conf`
