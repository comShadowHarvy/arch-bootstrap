#!/bin/bash
# This script gives nmap and etherape the necessary permissions to be run without sudo.
# It does this by setting capabilities on the executables.
# This script must be run with sudo.

set -e

NMAP_PATH=$(which nmap)
ETHERAPE_PATH=$(which etherape)

if [ -z "$NMAP_PATH" ]; then
    echo "nmap not found. Please install it."
    exit 1
fi

if [ -z "$ETHERAPE_PATH" ]; then
    echo "etherape not found. Please install it."
    exit 1
fi

echo "Setting capabilities for nmap at $NMAP_PATH"
sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip "$NMAP_PATH"

echo "Setting capabilities for etherape at $ETHERAPE_PATH"
sudo setcap cap_net_raw,cap_net_admin+eip "$ETHERAPE_PATH"

echo "Capabilities set successfully."
echo "You can now run nmap and etherape without sudo."
