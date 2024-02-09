# Arch Install

> WORK IN PROGRESS

This is my arch install guide written while I setup my Arch Linux install on my laptop. Windows is already installed and this guide is going to install Arch Linux as a **dual boot**.

For more than 4 years I have used this laptop for Computer Science college. I installed Windows and Arch Linux on the laptop. Although the Linux Operating works fine after more than 4 years, Windows is a different story. It might take 10 minutes just to get to the lock screen on Windows, even though I can boot Linux in less than a minute. One of the main reason why it's slow is that I used a spinning hard disk drive (HDD) for booting Windows. Therefore I decided to reinstall my Windows on a brand new SSD.

Fortunately, I can add an NVME SSD on my laptop, thus I can use the HDD as a backup drive. Here's what I did:

## 1. Preparation

I would install Arch Linux on the remaining 443GB unallocated space on the SSD, then I would reuse the HDD as a backup drive.

Hardware:

- Laptop (Acer Swift 3 - SF314-54G from 2018)

Drives:

- [WD Blue WD10SPZX](https://www.westerndigital.com/products/internal-drives/wd-blue-mobile-sata-hdd?sku=WD10SPZX) 1TB HDD
- [WD Black SN850X](https://www.westerndigital.com/products/internal-drives/wd-black-sn850x-nvme-ssd?sku=WDS100T2X0E) 1TB NVME SSD

Partitions:

- 1TB NVME SSD
  1. 100MB EFI (FAT32)
  2. 16MB Windows Reserved
  3. 447GB Windows C:\ (NTFS)
  4. 746MB Windows Recovery Environment
  5. **TODO: 443GB Linux (BTRFS)**
- 1TB HDD
  1. 1TB Backup (BTRFS) \*

> \* Read this [guide](./backup.md) on how to create my backup drive.

## 2. Boot the live USB

Download and create arch linux boot drive using this [guide](https://wiki.archlinux.org/title/USB_flash_installation_medium). To enter the live USB:

1. Turn off the computer.
2. Plug in the USB.
3. Enter the BIOS by turning on the computer and pressing F2 repeatedly.
4. Disable `Secure Boot`, change the `Boot Order` by putting the USB drive on the top of the boot order, and `Save and exit` on the BIOS.
5. Start the computer and enter the live USB environment.

## 3. Verify the boot mode

```sh
$ cat /sys/firmware/efi/fw_platform_size
64
```

Should outputs `64` to make sure it's using 64-bit x64 UEFI.

## 4. Connect to the internet

```text
$ iwctl

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

## 5. Partition the disks

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
> <https://community.acer.com/en/discussion/comment/809010/#Comment_809010>

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

## 6. Create BTRFS Partition

This instruction is for partition file `/dev/nvme0n1p5` with label `Linux` and
`/dev/nvme0n1p1` efi partition.

Format Partition to BTRFS:

```sh
mkfs.btrfs --label Linux /dev/nvme0n1p5
```

### 6.1. Create subvolumes in root filesystem

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
> <https://btrfs.readthedocs.io/en/latest/ch-mount-options.html>
>
> - `space_cache=v2`
> - `discard=async` autodetect device
> - `ssd` autodetect

### 6.2. Mount subvolumes and EFI

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

### 6.3. Enable swapfile

**16GB** for 12GB RAM computer:

```sh
btrfs filesystem mkswapfile --size 16G /mnt/swapfile
swapon /mnt/swapfile
```

## 7. Installation of essential packages

```sh
pacstrap -K /mnt base base-devel linux linux-firmware nvim networkmanager arch-install-scripts
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

## 8. Bootloader

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

Customize rEFInd: <https://rodsbooks.com/refind/themes.html#banners>

### 8.1. Secure boot

> TODO

## 9. Configure the system

```sh
pacman -Sy git tmux python ranger cron htop firefox btrfs-progs efibootmgr networkmanager man zoom speedometer eog
```

### 9.1. Network

Use [NetworkManager]() to connect to a Wifi

```sh
nmcli device wifi rescan
nmcli device wifi connect <SSID> password <PASSWORD>
```

### 9.2. Setup user

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

### 9.3. Install AUR helper

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

### 9.4. Window manager

With [Sway](https://wiki.archlinux.org/title/Sway)

```sh
yay -S sway swaylock swayidle swayimg swaybg greetd i3status papirus dunst xorg-wayland fuzzel
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

Set wallpaper

```sh
ln -sf "~/Pictures/Wallpapers/oshino shinobu linux.png" ~/.config/sway/wallpaper.png
```

> TODO change to gui greeter

### 9.5. Gnome

Hide close button:
<https://askubuntu.com/questions/948313/how-do-i-hide-disable-close-buttons-for-gnome-windows#948321>

```sh
gsettings set org.gnome.desktop.wm.preferences button-layout :
```

> TODO: uninstall gnome

### 9.6. Terminal

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

### 9.7. Clone dotfiles

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
cp -rf .git ~
cd ~
git reset --hard
```

Then make some commits!

### 9.8. Editor (Neovim)

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

### 9.9. SSH

```sh
yay -S openssh
```

Generate SSH key: (use defaults and no password)

```sh
ssh-keygen -t rsa -b 4096
```

Share `~/.ssh/id_rsa.pub` or save other PC's ssh keys on `~/.ssh/authorized_keys`.

### 9.10. Bluetooth

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

### 9.11. Audio

```sh
yay -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 pipewire-docs wireplumber rtkit pavucontrol
```

#### Fix no audio

> Acer Swift 3 SF314-54G
>
> ```sh
> lspci | grep audio
> #Multimedia audio controller: Intel Corporation Sunrise Point-LP HD Audio
> ```

```sh
yay -S sof-firmware
```

Source: <https://bbs.archlinux.org/viewtopic.php?id=265211>

Create `/etc/modprobe.d/sound.conf`:

```sh
options snd-intel-dspcfg dsp_driver=1
```

Then reboot.

### 9.12. Graphics

```sh
libva-mesa-driver
```

### 9.13. Other

```sh
yay -S extra/code
```

## Reference Links

- <https://wiki.archlinux.org/title/Installation_guide>
- <https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae>
- <https://wiki.archlinux.org/title/User:Altercation/Bullet_Proof_Arch_Install>
- <https://medium.com/the-foss-albatross/5-steps-to-set-up-your-new-sway-desktop-d3e0928c471f>
