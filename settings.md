# Settings

- Set journal limit

  Reason: To prevent slow startup

  source: https://wiki.archlinux.org/title/Systemd/Journal#Journal_size_limit

  ```sh
  # /etc/systemd/journald.conf
  SystemMaxUse=64M
  ```

- Cron job for low battery warning

  Run `crontab -e` and add:

  ```sh
  # !Copy some output of `env` here!
  * * * * * bash $HOME/scripts/battery-check.sh
  ```

- Trying to fix bumblebee after suspend

  Source: https://wiki.archlinux.org/title/Bumblebee#Enable_NVIDIA_card_after_waking_from_suspend

  ```sh
  # /etc/bumblebee/bumblebee.conf
  [driver-nvidia]
  PMMethod=bbswitch

  [driver-nouveau]
  PMMethod=bbswitch
  ```

  ```sh
  # /etc/tlp.conf
  RUNTIME_PM_BLACKLIST="01:00.0"
  ```

  Enable tlp

  ```sh
  $ sudo systemctl enable tlp
  $ sudo systemctl mask systemd-rfkill.service
  $ sudo systemctl mask systemd-rfkill.socket
  ```

- Allow change brightness to all users

  https://wiki.archlinux.org/title/Backlight#ACPI

  ```sh
  # /etc/udev/rules.d/backlight.rules
  RUN+="/bin/chmod a+w /sys/class/backlight/intel_backlight/brightness"
  ```

- Domain Name Server (DNS) with NetworkManager

  Global DNS.

  Source: https://wiki.archlinux.org/title/NetworkManager#Setting_custom_global_DNS_servers

  ```sh
  # /etc/NetworkManager/conf.d/dns-servers.conf
  # conf
  [global-dns-domain-*]
  servers=1.1.1.1,192.168.1.1
  ```

  Source: https://wiki.archlinux.org/title/NetworkManager#Setting_custom_DNS_servers_in_a_connection_(nmcli_/\_connection_file)
  Set dns for a specific connection. run:

  ```
  nmcli connection edit 'HotSpot - UI'
  nmcli> set ipv4.dns 1.1.1.1
  nmcli> save
  nmcli connection edit 'O420'
  nmcli> set ipv4.dns 1.1.1.1
  nmcli> save
  nmcli connection edit 'O420_plus'
  nmcli> set ipv4.dns 1.1.1.1
  nmcli> save
  ```

- SSH to termux Android

  ```sh
  scp -r "Downloads/dirname/" "scp://192.168.1.6:8022/~/storage/downloads/newdirname"
  ```

- Fix glitchy audio on bluetooth earbuds

  Source: https://wiki.archlinux.org/title/Bluetooth_headset#Connecting_works,\_but_there_are_sound_glitches_all_the_time

  ```sh
  pactl set-port-latency-offset bluez_card.38_8F_30_D7_3D_7D headset-output 100000
  pulseaudio -k
  pulseaudio --start
  ```

  Or set it in "Output Devices" > "Advanced" > "Latency offset" to 100.00.

  Use "A2DP" Profile for high quality listening, switch to "HFP" for recording with microphone.

- mpris-proxy

  ```sh
  yay mpris-proxy-service
  systemctl --user start mpris-proxy
  systemctl --user enable mpris-proxy
  ```

  Enable bluetooth controls to work on media players (Firefox included).
