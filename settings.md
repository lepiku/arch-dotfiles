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
