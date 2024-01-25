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
fdisk

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
pacstrap -K /mnt base base-devel linux linux-firmware vi nvim
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

# Network
echo 'okto-swifty' > /etc/hostname
```

> Replace `okto-swifty` with your own hostname

## 6. Configure the system

```sh
pacman -Sy git tmux python ranger cron htop firefox btrfs-progs efibootmgr networkmanager man
```

### 6.1. Bootloader

With [rEFInd](https://wiki.archlinux.org/title/REFInd):

```sh
pacman -Sy intel-ucode refind btrfs-progs
```

```sh
refind-install
```

Modify `/boot/refind_linux.conf` options (find you UUID in `/etc/fstab`):

```conf
"Boot with standard options"  "root=UUID=<Insert UUID> rw rootflags=subvol=@ loglevel=3"
"Boot to single-user mode"    "root=UUID=<Insert UUID> rw rootflags=subvol=@ loglevel=3 single"
"Boot with minimal options"   "ro root=/dev/nvme0n1p5"
```

Now you can reboot to your system!

```sh
reboot
```

### 6.2. Setup user

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

### 6.3. Install AUR Helper

After logged in as the user, install [yay](https://github.com/Jguer/yay):

```sh
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### 6.3. Window manager

With [Sway](https://wiki.archlinux.org/title/Sway)

```sh
yay -S sway swaylock swayidle swayimg swaybg greetd i3status
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

> TODO replace with gui greeter

### 6.4. Terminal

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

### 6.\_. Clone dotfiles

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

### 6.\_. Editor (Neovim)

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

### 6.4. SSH

```sh
yay -S openssh
```

Generate SSH key: (use defaults and no password)

```sh
ssh-keygen -t rsa -b 4096
```

### 6.\_. Audio

```sh
yay -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 pipewire-docs wireplumber rtkit
```

enable services:

```sh
systemctl
```
