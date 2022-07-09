#!/bin/sh

mount /dev/sda6 /mnt
mount /dev/sda1 /mnt/efi
mount /dev/sda9 /mnt/home
swapon /dev/sda5

cp /mnt/etc/fstab /mnt/etc/fstab.old
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<< "
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
"

swapoff /dev/sda5
umount -R /mnt
