#!/bin/bash

# Check if required arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <domain> <txt-value> [host-prefix]"
    echo "Example: $0 corponext.com.mx \"google-site-verification=...\""
    exit 1
fi

# Assign arguments to variables
DOMAIN="$1"
TXT_VALUE="$2"
# If a third argument isn't provided, it defaults to an empty string (root)
TXT_NAME="${3:-""}"

# Path to Plesk binary
PLESK_BIN="/usr/sbin/plesk"

echo "Adding TXT record to $DOMAIN..."

# On this version of Plesk:
# -txt is the VALUE/STRING
# -domain is the PREFIX/HOST
$PLESK_BIN bin dns --add "$DOMAIN" -txt "$TXT_VALUE" -domain "$TXT_NAME"

if [ $? -eq 0 ]; then
    echo "Success: TXT record added."
else
    echo "Error: Failed to add TXT record."
    exit 1
fi
