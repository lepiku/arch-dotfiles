#!/bin/sh

set -e

if ! ping -c 5 10.13.13.1
then
    # restart internet
    echo "Restarting internet..."
    nmcli connection up 'Auto Ethernet'
fi
