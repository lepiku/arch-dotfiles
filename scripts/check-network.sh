#!/bin/sh

set -e

if ! ping -c 5 10.13.13.1
then
    # restart internet
    echo "Restarting internet..."

    #nmcli connection down 'Auto Ethernet'
    #sleep 5
    #nmcli connection up 'Auto Ethernet'

    nmcli connection up 'O419_5G'
fi
