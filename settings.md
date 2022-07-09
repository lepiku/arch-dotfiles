# Settings

- https://wiki.archlinux.org/title/Systemd/Journal#Journal_size_limit

  ```sh
  # /etc/systemd/journald.conf
  SystemMaxUse=64M
  ```

- `crontab -e`
  ```sh
  # !Copy some output of `env` here!
  * * * * * bash $HOME/scripts/battery-check.sh
  ```
