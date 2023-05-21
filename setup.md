# Setup

Packages and configurations to-do after installing [Arch Linux](https://wiki.archlinux.org/).

## List of Packages to Install

### Linux

- refind
- dialog
- mtools
- dosfstools
- base-devel

### Terminal

- [st](#st)
- rxvt-unicode: Backup terminal
- zsh
- oh-my-zsh

### Tools

- [yay](#yay)
- neovim
- git
- tmux
- python
- go
- fzf
- nodejs
- arandr
- dunst: Notification
- redshift: Night light
- tree
- ranger
- reflector
- cron
- nvm
- htop
- [open-ssh](#ssh)
- xclip: Clipboard
- maim: Screenshot selection

### Apps

- visual-studio-code-bin
- dropbox
- firefox
- chromium
- calibre

### Window Manager (i3)

- xorg
- xorg-xinit
- i3-wm
- i3lock
- i3status
- dmenu
- rofi
- lightdm
- [lightdm-gtk-greeter](#lightdm-gtk-greeter)
- picom
- papirus-icon-theme
- xss-lock
- feh

### Network and Bluetooth

- networkmanager
- openssh
- network-manager-applet
- bluez
- bluez-utils
- blueman
- [mpris-proxy-service](#mpris)

### Audio

- pipewire
- pipewire-audio
- pipewire-pulse
- pipewire-alsa
- pavucontrol

### Font

- adobe-source-code-pro-fonts

## Configurations

### Windows Config

To fix [wrong datetime](https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows)
in dual boot setup, run in **Administrator** Command Prompt:

```cmd
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```

### st

clone `st` repo and configure `config.h`. Install it with:

```sh
sudo make clean install
```

### yay

```sh
pacman -S --needed git base-devel &&
git clone https://aur.archlinux.org/yay.git &&
cd yay &&
makepkg -si
```

### pacman

- Enable [parallel download](https://ostechnix.com/enable-parallel-downloading-in-pacman-in-arch-linux/)
  for pacman (optional config).
- Enable colored fonts.
- Ignore packages that should be updated manually.
- Enable multilib support (ex. to install `steam`).

```sh
# /etc/pacman.conf
ParallelDownloads = 4
Color
IgnorePkg   = miniconda3 postgresql postgresql-libs

[multilib]
Include = /etc/pacman.d/mirrorlist
```

### git

Set default name and email for git commits.

```sh
git config --global user.name Lepiku
git config --global user.email git.lepiku@gmail.com
```

### oh-my-zsh

Create symbolic links to plugins:

```sh
ln -s /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/
ln -s /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions ~/.oh-my-zsh/plugins/
```

### Bluetooth

**Start/enable** bluetooth on startup:

```sh
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service
```

~~Connect only with bluetoothctl. Pairing with `blueman` would not pair
correctly.~~

```sh
# bluetoothctl
# scan on
# pair <ID>
```

After updating `linux`, restart the computer to connect with a bluetooth device
properly.

#### MPRIS

Enable [bluetooth controls](https://wiki.archlinux.org/title/MPRIS#Bluetooth)
to work on media players (including Firefox).

```sh
yay -S mpris-proxy-service
systemctl --user start mpris-proxy
systemctl --user enable mpris-proxy
```

### ssh

Create ssh public/private key with:

```sh
ssh-keygen -c
```

### lightdm-gtk-greeter

Set enabled greeter

```sh
# /etc/lightdm/lightdm.conf
greeter-session=lightdm-gtk-greeter
```

Configure greeter:

```sh
# /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background=/usr/share/backgrounds/Pacil wallpaper final.png
theme-name=Arc-Dark
```
