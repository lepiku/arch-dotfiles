# Creating a Backup Drive

> WORK IN PROGRESS

My google drive free account storage is almost full and I don't want to pay a monthly subscription to backup my photos and videos from my phone.
So I decided to create my own backup.

After it is done, here are the steps to backup my gallery from my phone:

1. Connect my phone to computer 1 (main backup).
   ```text
   Phone >---(USB Cable or local network)---> Computer 1
   ```
2. Copy files from my phone to computer 1 (`/backup/backup-1/*`).
3. (optional) Create a btrfs snapshot in computer 1.
   > This is optional because a snapshot will automatically be created when I ran the `btrbk` command on step 5.
4. Connect computer 1 (main backup) to computer 2 (second backup).
   I can either connect them to the same network or with a network cable.
   ```text
   Computer 1 >--(Network cable or local network)--> Computer 2
   ```
5. Run the `btrbk` command from computer 2 to sync the files with computer 1.
6. **Done!** My files are backed up and I could delete backed up files from my phone to free its storage.

## 1. Considerations

There are some things to consider before creating this backup strategy.

Why:
The reason I choose this backup strategy is because I already have 2 computers (a desktop PC and a laptop) with free storage space, both running linux with one of them (desktop PC) already using btrfs.

What it **CAN** do:

- Backup my data on separate computers.
- Restore my data when one of my drive or computer broke.
- Sync backup without an internet connection.
- With slight modification, I can also use the same program to backup with:
  - 1 computer (Desktop PC or laptop) and 1 external hard drive
  - 2 external hard drive and a linux computer for running the backup program.

What it **CAN'T** do:

- Frequent backup:
  I need to connect my phone to computer 1 and later connect computer 1 to computer 2 to backup (create 2 copies of the same file).

  ```
  Computer 1 >--(Network cable or local network)--> Computer 2
  ```

### 1.1. Requirements

I installed this programs for my backup configuration:

- `btrfs`: Copy-on-write file system
- `btrbk`: backup utility for `btrfs`
- `sysstat` (optional): provide `iostat` to check disk write speed

To install them in arch linux, run:

```sh
pacman -S btrfs-progs btrbk sysstat
```

or in Ubuntu, run:

```sh
sudo apt install btrfs-progs btrbk sysstat
```

## 2. Create main backup directory on PC (Computer 1)

My plan is to create a new btrfs subvolume in `/backup/backup-1`. Everytime I want to backup, I would copy my files here and create a snapshot of it.

> WIP: only create dir and group, no need for a new user

```sh
# Create group
sudo groupadd backup
sudo gpasswd -a $USER backup # add the user to the backup group

# Create backup directory (TO-TRY)
sudo mkdir /backup
sudo chgrp backup /backup
sudo chmod 750 /backup

# Create btrfs subvolume
sudo mount /dev/nvme0n1p5 /mnt
sudo btrfs subvolume create /mnt/@backup-1
sudo umount /mnt

# mount subvolume and save to fstab
sudo mount -o nosuid,nodev,noatime,compress=zstd,subvol=@backup-1 /dev/nvme0n1p5 /backup/backup-1
genfstab -U / # verify mount options
```

For more about btrfs mount options, read [btrfs mount options](https://btrfs.readthedocs.io/en/latest/ch-mount-options.html).

Optional: To mount the backup partition on boot, edit the `/etc/fstab`:

```sh
genfstab -U / | sudo tee -a /etc/fstab
sudoedit /etc/fstab # delete duplicate entries
```

Then start putting the files to `/backup/backup-1/*`!

## 3. Create a backup directory on the laptop (Computer 2)

```sh
# Create group
sudo groupadd backup
sudo gpasswd -a $USER backup # add the user to the backup group
```

> TODO: backup ssh config

### 3.1. (Optional) Wipe the drive

Because I have previously used the drive, I wanted to wipe the drive to make sure that all my previous unencrypted data is erased.

> <span style="color: red">WARNING!</span> Make sure it's the correct drive. This example uses `/dev/sda`.

```sh
sudo shred -v -n 1 --random-source=/dev/urandom -z /dev/sda
```

While running `shred`, you can log log its progress by running:

```sh
while :
do
    sudo iostat -dmxy sda 1 1 \
        | awk -v date=`date +%T` \
        '$1 == "sda" { printf("%s,%s,%s,%s,%s,%s,%s\n", $1,$8,$9,$14,$15,$23,date) }' \
        >> sda-shred-stats.csv
done
```

### 3.2. Create Partition

Create empty partition

> Replace `/dev/sda` with the drive you want to create

```sh
sudo fdisk /dev/sda

# Create empty gpt partition table, wiping the drive
# WARNING! All data will be lost on write (w ENTER)!
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

### 3.3. Encrypt with LUKS

Create a key file, so I don't have to input a password everytime I want to unlock:

```sh
sudo dd bs=512 count=4 if=/dev/urandom of=/root/backup-keyfile iflag=fullblock
sudo chmod 600 /root/backup-keyfile
```

Ecrypt the drive/partition:

```sh
sudo cryptsetup luksFormat /dev/sda1 /root/backup-keyfile
```

### 3.4. Create a btrfs paritition

After encrypting the drive, unlock them:

```sh
sudo cryptsetup open --key-file /root/backup-keyfile /dev/sda1 backup
```

> I will have to unlock the partition with `cryptsetup open` everytime I want to mount the partition.
> To unlock or mount them on boot, edit the `/etc/fstab`.
>
> ```sh
> backup UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /root/backup-keyfile luks,noearly
> ```

Then, create a btrfs partition

```sh
sudo mkfs.btrfs --label Backup /dev/mapper/backup
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
#UUID:               xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
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

### 3.5. Mount and unmount commands

To unlock and mount them:

```sh
sudo cryptsetup open --key-file /root/backup-keyfile /dev/sda1 backup
sudo mount -o nosuid,nodev,noatime,compress=zstd:9,autodefrag /dev/mapper/backup /backup/btr-backup
```

To unmount and lock them:

```sh
sudo umount /backup/btr-backup
sudo cryptsetup close backup
```
