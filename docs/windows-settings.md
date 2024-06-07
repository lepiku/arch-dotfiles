# Windows Settings

- [Disable expiring password for local account](https://www.elevenforum.com/t/enable-or-disable-password-expiration-in-windows-11.10277/#Two)

  Run in `cmd`:
  
  ```cmd
  wmic UserAccount where Name="username" set PasswordExpires=True
  ```

  > Replace `username` with your username
