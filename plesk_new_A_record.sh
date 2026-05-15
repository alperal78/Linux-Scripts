### Bash Script: Add Plesk A Record
```bash
#!/bin/bash

# Check if required arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <domain> <ip-address> [host-prefix]"
    echo "Example: $0 corponext.com.mx 192.168.1.100 dev"
    exit 1
fi

# Assign arguments to variables
DOMAIN="$1"
IP_ADDRESS="$2"
# Default to empty string for root domain
HOST_NAME="${3:-""}"

# Path to Plesk binary
PLESK_BIN="/usr/sbin/plesk"

echo "Adding A record to $DOMAIN..."

# According to your help:
# -a defines the host ('' for root)
# -ip defines the target IP
$PLESK_BIN bin dns --add "$DOMAIN" -a "$HOST_NAME" -ip "$IP_ADDRESS"

if [ $? -eq 0 ]; then
    echo "Success: A record added."
else
    echo "Error: Failed to add A record."
    exit 1
fi
