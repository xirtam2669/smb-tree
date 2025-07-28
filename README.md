# smbmap-tree.sh

A Bash script to enumerate and optionally download files from accessible SMB shares on a target host.

## Features

- Enumerates all SMB shares readable or writable by the provided credentials.
- Optionally downloads **all accessible files** from shares.
- Clean output and error handling.
- Organized directory structure for downloads.

---

## Usage

```bash
./smbmap-tree.sh -i <ip> -u <username> -p <password> [-D]
