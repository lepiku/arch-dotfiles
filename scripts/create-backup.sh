#!/bin/sh
# Creates BTRFS snapshot

sudo btrfs subvol snapshot -r / /.snapshots/root/root_$(date +%Y%m%d_%H%M%S)
sudo btrfs subvol snapshot -r /home /.snapshots/home/home_$(date +%Y%m%d_%H%M%S)
