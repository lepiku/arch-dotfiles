# Arch Install

Links

- https://wiki.archlinux.org/title/Installation_guide

## 1. Verify the boot mode:

```sh
cat /sys/firmware/efi/fw_platform_size
64
```

Should outputs `64`

## 2. Connect to the internet

```text
iwctl

[iwd]# device list
Ex: <Device Name> is wlan0
Ex: <Adapter> is phy0

[iwd]# device wlan0 set-property Powered on
[iwd]# adapter phy0 set-property Powered on
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
Ex: <SSID> is LePC

[iwd]# station wlan0 connect LePC
Enter Passphrase:

[iwd]# station wlan0 show
[iwd]# exit
```

Update the clock:

```sh
timedatectl
```

## 3. Partition the disks

Check your SSD/HDD:

```sh
lsblk
```

> If NVME isn't detected:
>
> - Open BIOS
> - Change `SATA Operation` mode to `AHCI`
> - Save Changes in BIOS
>
> https://community.acer.com/en/discussion/comment/809010/#Comment_809010

Current structure:

1. 100MB EFI
2. 16MB Windows Reserved
3. 447GB Windows C:
4. 746MB Windows Recovery Environment
5. 443GB Unallocated **(To-do install Linux Here)**

Create linux partition with `fdisk`:

```sh
fdisk /dev/nvme0n1p5

# m for help
m ENTER

# print partition table
p ENTER

# new partition
n ENTER
ENTER # default partition number
ENTER # default start, at the begining of unallocated
ENTER # default end, at the end of the drive

# print partition table, check the new partition
p ENTER

# write changes, no permanent changes before writing happened
w ENTER
```

## 4. Create BTRFS Partition

This instruction is for partition file `/dev/nvme0n1p5` with label `Linux` and
`/dev/nvme0n1p1` efi partition.

Format Partition to BTRFS:

```sh
mkfs.btrfs --label Linux /dev/nvme0n1p5
```

### 4.1. Create subvolumes in root filesystem

```sh
mount /dev/nvme0n1p5 /mnt
btrfs subvolumes create /mnt/@          # /
btrfs subvolumes create /mnt/@home      # /home
btrfs subvolumes create /mnt/@snapshots # /.snapshots
btrfs subvolumes create /mnt/@varlog    # /var/log
btrfs subvolumes create /mnt/@varcache  # /var/cache
umount /mnt
```

> Default mount options:
>
> https://btrfs.readthedocs.io/en/latest/ch-mount-options.html
>
> - `space_cache=v2`
> - `discard=async` autodetect device
> - `ssd` autodetect

### 4.2. Mount subvolumes and EFI

My mount options:

- `noatime` significantly improves performance
- `zstd` defaults to level `3`

To mount them, run:

```sh
o_btrfs=noatime,compress=zstd

# mount btrfs
mount -o $o_btrfs,subvol=@          /dev/nvme0n1p5 /mnt
mkdir -p /mnt/home /mnt/.snapshots /mnt/var/log /mnt/var/cache /mnt/efi
mount -o $o_btrfs,subvol=@home      /dev/nvme0n1p5 /mnt/home
mount -o $o_btrfs,subvol=@snapshots /dev/nvme0n1p5 /mnt/.snapshots
mount -o $o_btrfs,subvol=@varlog    /dev/nvme0n1p5 /mnt/var/log
mount -o $o_btrfs,subvol=@varcache  /dev/nvme0n1p5 /mnt/var/cache

# mount efi
mount /dev/nvme0n1p1 /mnt/efi
```

### 4.3. Enable swapfile

**16GB** for 12GB RAM computer:

```sh
btrfs filesystem mkswapfile --size 16G /mnt/swapfile
swapon /mnt/swapfile
```

## 5. Installation of essential packages

```sh
pacstrap -K /mnt base base-devel linux linux-firmware nvim networkmanager
```

Generate `fstab` and enter chroot:

```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab # check the fstab

arch-chroot /mnt
```

Run inside chroot:

```sh
# Time
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc

# Localization
locale-gen
vi /etc/locale.gen # uncomment en_US.UTF-8 UTF-8
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Set computer name as 'okto-swifty'
echo 'okto-swifty' > /etc/hostname
```

## 6. Bootloader

With [rEFInd](https://wiki.archlinux.org/title/REFInd):

```sh
pacman -Sy intel-ucode refind btrfs-progs mkinitcpio-firmware
```

Install bootloader (rEFInd):

```sh
refind-install
```

Modify `/boot/refind_linux.conf` options (find you UUID in `/etc/fstab`):

```conf
"Boot with standard options"  "root=UUID=<Insert UUID> rw rootflags=subvol=@ loglevel=3"
"Boot to single-user mode"    "root=UUID=<Insert UUID> rw rootflags=subvol=@ loglevel=3 single"
"Boot with minimal options"   "ro root=/dev/nvme0n1p5"
```

Set background/banner:

```sh
scp "scp://192.168.1.24/Pictures/Wallpapers/Pacil/grub pacil 80.png" Downloads/bootloader_pacil_80.png
sudo cp Downloads/bootloader_pacil_80.png /efi/EFI/refind/
sudoedit /efi/EFI/refind/refind.conf
# add 'banner bootloader_pacil_80.png'
# uncomment 'banner_scale fillscreen'
```

Now you can reboot to your system!

```sh
reboot
```

Customize rEFInd: https://rodsbooks.com/refind/themes.html#banners

### 6.1. Secure boot

> TODO

## 7. Configure the system

```sh
pacman -Sy git tmux python ranger cron htop firefox btrfs-progs efibootmgr networkmanager man zoom speedometer eog
```

### 7.1. Network

Use [NetworkManager]() to connect to a Wifi

```sh
nmcli device wifi rescan
nmcli device wifi connect <SSID> password <PASSWORD>
```

### 7.2. Setup user

```sh
pacman -Sy sudo zsh
```

Set password for root

```sh
# Root password (oot6)
passwd
```

Create your user, creating user `dimas`:

```sh
useradd -mG wheel dimas
passwd dimas

# uncomment `%wheel ALL=(ALL:ALL) ALL`
# to allow users in the wheel group to use sudo
EDITOR=nvim visudo
```

### 7.3. Install AUR Helper

After logged in as the user, install [yay](https://github.com/Jguer/yay):

```sh
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

Update pacman mirrorlist with `reflector`:

```sh
yay -S reflector
sudo reflector --latest 10 --country SG,ID --protocol https --save /etc/pacman.d/mirrorlist --sort score
```

### 7.3. Window manager

With [Sway](https://wiki.archlinux.org/title/Sway)

```sh
yay -S sway swaylock swayidle swayimg swaybg greetd i3status papirus dunst xorg-wayland
```

Edit `/etc/greetd/config.toml` to launch sway on login

```conf
[default_session]
command = "agreety --cmd sway"
```

Create symbolic link for `i3status` config:

```sh
ln -s ~/.config/i3status/config-swifty ~/.config/i3status/config
```

Start and Enable `greetd`

```sh
sudo systemctl enable greetd.service
sudo systemctl start greetd.service
```

> TODO change to gui greeter

### 7.\_. Gnome

Hide close button:
https://askubuntu.com/questions/948313/how-do-i-hide-disable-close-buttons-for-gnome-windows#948321

```sh
gsettings set org.gnome.desktop.wm.preferences button-layout :
```

### 7.4. Terminal

With [foot](https://codeberg.org/dnkl/foot#index) and
[oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)

```sh
yay -S foot zsh fzf fd zsh-autosuggestions zsh-syntax-highlighting
```

Change user shell to `zsh`:

```sh
chsh
#Password:
#Shell: /bin/zsh
```

Create symbolic link to zsh plugins in `~/.oh-my-zsh`:

```sh
ln -s /usr/share/zsh/plugins ~/.oh-my-zsh
```

### 7.\_. Clone dotfiles

Clone git on another directory, example:

```sh
mkdir -p ~/Projects/github
git clone git@github.com:lepiku/arch-dotfiles.git
cd ~/Projects/github/arch-dotfiles
git checkout wayland
```

Copy files to home:

```sh
cd ~/Projects/github/arch-dotfiles
cp -r .config/* ~/.config
cp -rf .bashrc bin/ .condarc .dispad .fehbg .git/ .gitignore .global-gitignore markdowns/ .oh-my-zsh/ .profile README.md scripts/ .termux/ .tmux.conf .vimrc .xinitrc .Xresources .zsh_aliases .zshrc ~/
```

Then copy

### 7.\_. Editor (Neovim)

```sh
yay -S neovim nodejs npm
```

> Nodejs and NPM needed for some Neovim plugins

Install [vim-plug](https://github.com/junegunn/vim-plug):

```sh
sh -c 'curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

Then, install plugins:

```sh
nvim
#:PlugInstall
```

### 7.4. SSH

```sh
yay -S openssh
```

Generate SSH key: (use defaults and no password)

```sh
ssh-keygen -t rsa -b 4096
```

Share `~/.ssh/id_rsa.pub` or save other PC's ssh keys on `~/.ssh/authorized_keys`.

### 7.\_. Bluetooth

```sh
yay -S bluez bluez-utils
```

Enable bluetooth

```sh
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
rfkill unblock bluetooth
sudoedit /etc/bluetooth/main.conf # uncomment 'AutoEnable=true'
```

Connect with your bluetooth device

```sh
bluetoothctl
#scan on
#pair <device>
#connect <device>
#trust <device>
#exit
```

### 7.\_. Audio

```sh
yay -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 pipewire-docs wireplumber rtkit pavucontrol
```

#### 7.\_.1. Fix no audio

> Acer Swift 3 SF314-54G
>
> ```sh
> lspci | grep audio
> #Multimedia audio controller: Intel Corporation Sunrise Point-LP HD Audio
> ```

```sh
yay -S sof-firmware
```

Source: https://bbs.archlinux.org/viewtopic.php?id=265211

Create `/etc/modprobe.d/sound.conf`:

```sh
options snd-intel-dspcfg dsp_driver=1
```

Then reboot.

## Backup Drive

### Create Partition

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

Partition #1 contains a vfat signature.
Do you want to remove the signature? [Y]es/[N]o: y

# print partition table, check the new partition
p ENTER

# write changes, no permanent changes before writing happened
w ENTER
```

Format Partition to BTRFS:

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

### Set Permissions

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
