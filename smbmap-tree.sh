#!/bin/bash

ip=""
user=""
pass=""
download=false
output_dir="downloads"

usage() {
    echo "Usage: $0 -i <ip> -u <username> -p <password> [-D]"
    echo ""
    echo "  -i   Target IP address or hostname"
    echo "  -u   SMB username"
    echo "  -p   SMB password"
    echo "  -D   (Optional) Enable auto-download of accessible files"
    echo ""
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi

# Parse arguments
while getopts ":i:u:p:Dh" opt; do
    case $opt in
        i) ip="$OPTARG" ;;
        u) user="$OPTARG" ;;
        p) pass="$OPTARG" ;;
        D) download=true ;;
        h) usage ;;
        \?) echo "[!] Invalid option: -$OPTARG" >&2; usage ;;
        :) echo "[!] Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

# Require essential fields
if [[ -z "$ip" || -z "$user" || -z "$pass" ]]; then
    echo "[!] Missing required arguments."
    usage
fi

echo "[*] Target: $ip"
echo "[*] Username: $user"
echo "[*] Auto-download: $download"
echo "[*] Enumerating accessible shares..."

mkdir -p "$output_dir"

# Get readable or writable shares
shares=$(smbmap -H "$ip" -u "$user" -p "$pass" 2>/dev/null | awk '/READ|WRITE/ {print $1}')

if [[ -z "$shares" ]]; then
    echo "[!] No accessible shares found."
    exit 1
fi

# Enumerate and optionally download
for share in $shares; do
    echo -e "\n[*] Recursing into share: $share"

    if $download; then
        share_dir="$output_dir/$share"
        mkdir -p "$share_dir"

        smbclient //"$ip"/"$share" -U "$user%$pass" -c "prompt OFF; recurse ON; lcd $share_dir; mget *" 2>/dev/null

        echo "[+] Downloaded contents of share '$share' to $share_dir"
    else
        smbmap -H "$ip" -u "$user" -p "$pass" -R "$share"
    fi
done

echo -e "\n[✔] Done."
