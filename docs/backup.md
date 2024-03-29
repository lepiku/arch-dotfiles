# Creating a Backup Drive

> WORK IN PROGRESS

```sh
yay -S btrbk sysstat
```

- `btrbk`: backup utility
- `sysstat`: provide `iostat` to check disk write speed

## Create `backup` User on PC

```sh
# Create user
sudo useradd -m backup          # create user with home
sudo passwd backup              # set password
sudo gpasswd -a dimas backup    # add dimas to backup group

# Create backup directory
su backup
    chmod 755 /home/backup
    mkdir /home/backup/backup-1
    chmod 775 /home/backup/backup-1
exit

# Create btrfs subvolume
sudo mount /dev/nvme0n1p5 /mnt
sudo btrfs subvolume create /mnt/@backup-1
sudo umount /mnt

# mount subvolume and save to fstab
sudo mount -o nosuid,nodev,noatime,compress=zstd,subvol=@backup-1 /dev/nvme0n1p5 /home/backup/backup-1
genfstab -U /                   # verify mount options
sudoedit /etc/fstab             # add the partition to mount on boot
```

Then put files to backup on `/home/backup/backup-1`!

## Create `backup` User on Laptop

```sh
# Create user
sudo useradd -m backup          # create user with home
sudo passwd backup              # set password

# Create backup directory
su backup
    chmod 755 /home/backup
    mkdir /home/backup/backup-1
    chmod 775 /home/backup/backup-1
exit
```

> TODO: backup ssh config

## Wipe the drive

> <span style="color: red">WARNING!</span> Make sure it's the correct drive.
> This example uses `/dev/sda`.

```sh
sudo shred -v -n 1 --random-source=/dev/urandom -z /dev/sda
```

Log write speed to a file:

```sh
while :
do
    sudo iostat -dmxy sda 1 1 \
        | awk -v date=`date +%T` \
        '$1 == "sda" { printf("%s,%s,%s,%s,%s,%s,%s\n", $1,$8,$9,$14,$15,$23,date) }' \
        >> sda-shred-stats.csv
done
```

## Create Partition

Create empty partition

> Replace `/dev/sda` with the drive you want to create

```sh
sudo fdisk /dev/sda

# Create empty gpt partition table, wiping the drive
# WARNING! All data will be lost (on write)!
g ENTER

# create new linux partition
n ENTER
ENTER # default partition number
ENTER # default start, at the begining of unallocated
ENTER # default end, at the end of the drive

# print partition table, check the new partition
p ENTER

# write changes, no permanent changes before writing happened
w ENTER
```

## Encrypt with LUKS

```sh
su backup
cd
dd bs=512 count=4 if=/dev/urandom of=backup-keyfile iflag=fullblock
```

```sh
PART=/dev/sda1
sudo cryptsetup
```

> TODO view history in bash

## Format Partition to BTRFS

```sh
sudo mkfs.btrfs --label Backup /dev/sda1
#btrfs-progs v6.7
#See https://btrfs.readthedocs.io for more information.
#
#Performing full device TRIM /dev/sda1 (931.51GiB) ...
#NOTE: several default settings have changed in version 5.15, please make sure
#      this does not affect your deployments:
#      - DUP for metadata (-m dup)
#      - enabled no-holes (-O no-holes)
#      - enabled free-space-tree (-R free-space-tree)
#
#Label:              Backup
#UUID:               d9969466-c979-4244-8d05-bb3cc767a736
#Node size:          16384
#Sector size:        4096
#Filesystem size:    931.51GiB
#Block group profiles:
#  Data:             single            8.00MiB
#  Metadata:         DUP               1.00GiB
#  System:           DUP               8.00MiB
#SSD detected:       no
#Zoned device:       no
#Incompat features:  extref, skinny-metadata, no-holes, free-space-tree
#Runtime features:   free-space-tree
#Checksum:           crc32c
#Number of devices:  1
#Devices:
#   ID        SIZE  PATH
#    1   931.51GiB  /dev/sda1
```

Mount options:

- noatime: best for Copy-on-write format
- compress: higher zstd compression because it's for backup

```sh
o_btrfs=noatime,compress=zstd:9
```

## Set Permissions

Add user to storage group

```sh
sudo gpasswd -a dimas storage
```

Create policy to allow mounting by `storage` group in `/etc/polkit-1/rules.d/10-udisk2.rules`

```text
// See the polkit(8) man page for more information
// about configuring polkit.

// Allow udisks2 to mount devices without authentication
// for users in the "storage" group.
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
         action.id == "org.freedesktop.udisks2.filesystem-mount") &&
        subject.isInGroup("storage")) {
        return polkit.Result.YES;
    }
});
```

Set mount options for that partition in `/etc/udisks2/mount_options.conf`

> Replace parititon UUID with your own UUID

```conf
# This file contains custom mount options for udisks 2.x
# Typically placed at /etc/udisks2/mount_options.conf

[/dev/disk/by-uuid/d9969466-c979-4244-8d05-bb3cc767a736]
btrfs_defaults=noatime,compress=zstd:9
```
