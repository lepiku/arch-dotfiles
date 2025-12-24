#!/bin/sh

set -e

case $1 in
    vpn-on)
        echo "Enabling VPN..."
        sudo systemctl start wg-quick@peer2.service
        ;;
    vpn-off)
        echo "Disabling VPN..."
        sudo systemctl stop wg-quick@peer2.service
        ;;

    mount)
        echo 'Mounting...'
        sudo cryptsetup open --key-file /root/backup-keyfile /dev/sda1 backup
        sudo mount -o nosuid,nodev,noatime,compress=zstd:9,autodefrag /dev/mapper/backup /backup
        ;;
    unmount)
        echo 'Unmounting...'
        sudo umount /backup
        sudo cryptsetup close backup
        ;;

    sync-okuto)
        ssh -t archpc.okuto.id /server/scripts/backup-okuto.sh
        ;;

    backup)
        echo 'Backing up...'
        sudo btrbk run --progress -v -c /etc/btrbk/archpc-server.conf
        ;;
    backup-local)
        echo 'Backing up (local)...'
        sudo btrbk run --progress -v -c /etc/btrbk/local-archpc-server.conf
        ;;

    run)
        $0 vpn-on
        $0 mount
        $0 sync-okuto
        $0 backup
        $0 unmount
        $0 vpn-off
        ;;
    run-local)
        $0 vpn-on
        $0 mount
        $0 sync-okuto
        $0 backup-local
        $0 unmount
        $0 vpn-off
        ;;
    *)
        echo Unknown command $1
        exit 1
esac
