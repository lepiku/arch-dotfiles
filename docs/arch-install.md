# Arch Install

> WORK IN PROGRESS

This is my arch install guide written while I setup my Arch Linux install on my laptop.
Windows is already installed and this guide is going to install Arch Linux as a **dual boot**.

Background:
For more than 4 years I have used this laptop for Computer Science study at my college.
I installed Windows and Arch Linux on the laptop.
Although the Linux Operating works fine after more than 4 years, Windows is a different story.
It might take 10 minutes just to get to the lock screen on Windows, even though I can boot Linux in less than a minute.
One of the main reason why it's slow is that I used a spinning hard disk drive (HDD) for booting Windows.
Therefore, I decided to reinstall my Windows on a brand new SSD.
Fortunately, I can add an NVME SSD on my laptop, thus I can use the HDD as a backup drive.

## 1. Preparation

I would install Arch Linux on the remaining 443GB unallocated space on the SSD, then I would reuse the HDD as a backup drive.

My hardware:

- Laptop ([Acer Swift 3 SF314-54G](https://www.acer.com/us-en/support/product-support/SF314-54G/) from 2018)

My drives:

- [WD Blue WD10SPZX](https://www.westerndigital.com/products/internal-drives/wd-blue-mobile-sata-hdd?sku=WD10SPZX) 1TB HDD
- [WD Black SN850X](https://www.westerndigital.com/products/internal-drives/wd-black-sn850x-nvme-ssd?sku=WDS100T2X0E) 1TB NVME SSD

Drive partitions:

- 1TB NVME SSD
  1. 100MB EFI (FAT32)
  2. 16MB Windows Reserved
  3. 447GB Windows C:\ (NTFS)
  4. 746MB Windows Recovery Environment
  5. **TODO: 443GB Linux (BTRFS)**
- 1TB HDD
  1. 1TB Backup (BTRFS) \*

> \* Read this [guide](./backup.md) on how I created my backup drive and setup.

## 2. Boot the live USB

Download and create arch linux boot drive using this [guide](https://wiki.archlinux.org/title/USB_flash_installation_medium). To enter the live USB:

1. Turn off the computer.
2. Plug in the USB.
3. Enter the BIOS by turning on the computer and pressing `F2` repeatedly.
4. Disable `Secure Boot`, change the `Boot Order` by putting the USB drive on the top of the boot order, and `Save and exit` on the BIOS.
5. Start the computer and enter the live USB environment.

## 3. Verify the boot mode

```sh
$ cat /sys/firmware/efi/fw_platform_size
64
```

Should outputs `64` to make sure it's using 64-bit x64 UEFI.

## 4. Connect to the internet

Connect to the wifi network.

```text
$ iwctl

[iwd]# device list
```

> For example:
> `<Device Name>` is `wlan0`,
> `<Adapter>` is `phy0`, and
> `<SSID>` is `LePC`.

```text
[iwd]# device wlan0 set-property Powered on
[iwd]# adapter phy0 set-property Powered on
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
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

> If your NVME SSD isn't detected:
>
> - Enter BIOS
> - Change `SATA Operation` mode to `AHCI`
> - Save Changes in BIOS
>
> <https://community.acer.com/en/discussion/comment/809010/#Comment_809010>

Before:

1. 100MB EFI (FAT32)
2. 16MB Windows Reserved
3. 447GB Windows C:\ (NTFS)
4. 746MB Windows Recovery Environment
5. **443GB Unallocated**

Create a linux partition with `fdisk`:

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

After:

1. 100MB EFI (FAT32)
2. 16MB Windows Reserved
3. 447GB Windows C:\ (NTFS)
4. 746MB Windows Recovery Environment
5. **443GB Linux (Unformatted)**

## 6. Create BTRFS Partition

> This instruction to create a `Linux` labeled partition for `/dev/nvme0n1p5` and had an EFI partition at `/dev/nvme0n1p1`.

Format Partition to BTRFS:

```sh
mkfs.btrfs --label Linux /dev/nvme0n1p5
```

### 6.1. Create subvolumes in root filesystem

Commands to create subvolumes:

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
> - `space_cache=v2`
> - `discard=async` autodetect device
> - `ssd` autodetect
>
> <https://btrfs.readthedocs.io/en/latest/ch-mount-options.html>

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

### 6.3. Create swapfile

Find the recommended swap size for your computer RAM:

<https://itsfoss.com/swap-size/#how-much-should-be-the-swap-size>

I decided to create a **16GB** swap file for my computer which has 12GB RAM with hibernation:

```sh
btrfs filesystem mkswapfile --size 16G /mnt/swapfile
swapon /mnt/swapfile
```

> To enable hibernation, read [here](#11.10.-hibernation).

## 7. Installation of Arch Linux

```sh
pacstrap -K /mnt base base-devel linux linux-firmware nvim networkmanager arch-install-scripts
```

Generate `fstab` and enter chroot:

```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab # check the fstab

arch-chroot /mnt
```

Update time and locale inside chroot:

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

## 8. Install Bootloader

With [rEFInd](https://wiki.archlinux.org/title/REFInd):

```sh
pacman -Sy refind intel-ucode btrfs-progs
```

Install rEFInd:

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

> To fix [mkinitcpio warnings](https://wiki.archlinux.org/title/Mkinitcpio#Possibly_missing_firmware_for_module_XXXX), install `mkinitcpio-firmware` from AUR.

### 8.1. Secure boot

> TODO

## 9. Configure the system

```sh
pacman -Sy git tmux python ranger cron htop firefox btrfs-progs efibootmgr networkmanager man zoom speedometer eog
```

### 9.1. Network

```sh
pacman -S nm-connection-editor
```

Use [NetworkManager]() to connect to a Wifi

```sh
nmcli device wifi rescan
nmcli device wifi connect <SSID> password <PASSWORD>
```

or with `nmtui`:

```sh
nmtui
```

### 9.2. Setup user

Install `sudo` and `zsh`:

```sh
pacman -Sy sudo zsh
```

Set password for root

```sh
# Root password (oot6)
passwd root
```

Create your user. Create `dimas` user and add it to `wheel` group so that the user can run sudo:

```sh
useradd -mG wheel dimas
passwd dimas

# uncomment `%wheel ALL=(ALL:ALL) ALL`
# to allow users in the wheel group to use sudo
EDITOR=nvim visudo
```

## 10. Reboot to your Arch Linux

Reboot

```sh
reboot
```

Enter the BIOS and change the `boot order` to put NVME SSD on the top of the order, then `Save and exit`.

## 11. Install more programs

Configs can be viewed in this [repository](https://github.com/lepiku/arch-dotfiles).

### 11.1. AUR helper

Install [yay](https://github.com/Jguer/yay):

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

### 11.2. Window manager

Install [Sway](https://wiki.archlinux.org/title/Sway):

```sh
yay -S sway swaylock swayidle swayimg swaybg greetd i3status papirus dunst xorg-wayland fuzzel
```

Edit `/etc/greetd/config.toml` to launch sway on login:

```conf
[default_session]
command = "agreety --cmd sway"
```

Create symbolic link for `i3status` config:

```sh
ln -s ~/.config/i3status/config-swifty ~/.config/i3status/config
```

Start and Enable `greetd`:

```sh
sudo systemctl enable greetd.service
sudo systemctl start greetd.service
```

Set the wallpaper:

```sh
scp "scp://192.168.1.24/Pictures/Wallpapers/oshino shinobu linux.png" Pictures/Wallpapers
ln -sf "~/Pictures/Wallpapers/oshino shinobu linux.png" ~/.config/sway/wallpaper.png
```

> TODO: change greeter to use graphical UI

### 11.3. Terminal

With [foot](https://codeberg.org/dnkl/foot#index) and
[oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)

```sh
yay -S foot zsh aur/oh-my-zsh-git fzf fd zsh-autosuggestions zsh-syntax-highlighting
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

### 11.5. Clone dotfiles

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

### 11.6. Editor (Neovim)

```sh
yay -S neovim nodejs npm
```

> Node and NPM are needed for some Neovim plugins

Install [vim-plug](https://github.com/junegunn/vim-plug):

```sh
sh -c 'curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

Install plugins listed in [`init.vim`](./.config/nvim/init.vim):

```sh
nvim
#:PlugInstall
```

Restart Neovim to install [`coc.nvim`](https://github.com/neoclide/coc.nvim) plugins:

```sh
#:q
nvim
```

### 11.7. SSH

Install [openssh](https://wiki.archlinux.org/title/OpenSSH):

```sh
yay -S openssh
```

Generate SSH key:

```sh
ssh-keygen -t rsa -b 4096
# Use default on all prompts
```

Share `~/.ssh/id_rsa.pub` or save other PC's ssh keys on `~/.ssh/authorized_keys`.

### 11.8. Bluetooth

install [bluez](https://wiki.archlinux.org/title/Bluetooth):

```sh
yay -S bluez bluez-utils
```

Enable bluetooth:

```sh
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
sudoedit /etc/bluetooth/main.conf # uncomment 'AutoEnable=true'
```

Connect with your bluetooth device:

```sh
bluetoothctl

scan on
pair <device>
connect <device>
trust <device>
exit
```

#### 11.8.1. Sync audio devices on Linux and Windows

> TODO

### 11.9. Audio

Install [PipeWire](https://wiki.archlinux.org/title/PipeWire) and other tools:

```sh
yay -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-v4l2 pipewire-docs wireplumber rtkit pavucontrol
```

#### Fix no audio on Acer Swift 3 SF314-54G

Make sure the audio device is detected:

```sh
lspci | grep audio
#Multimedia audio controller: Intel Corporation Sunrise Point-LP HD Audio
```

Install sof-firmware

```sh
yay -S sof-firmware
```

add audio module options by creating `/etc/modprobe.d/sound.conf`:

```text
options snd-intel-dspcfg dsp_driver=1
```

> <https://bbs.archlinux.org/viewtopic.php?id=265211>

Then reboot.

### 11.10. Hibernation

TODO btrfs hibernation

### 11.11. Graphics

```sh
libva-mesa-driver
```

### 11.12. Other

```sh
yay -S extra/code tk pyenv nvm
```

## Reference Links

- <https://wiki.archlinux.org/title/Installation_guide>
- <https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae>
- <https://wiki.archlinux.org/title/User:Altercation/Bullet_Proof_Arch_Install>
- <https://medium.com/the-foss-albatross/5-steps-to-set-up-your-new-sway-desktop-d3e0928c471f>
