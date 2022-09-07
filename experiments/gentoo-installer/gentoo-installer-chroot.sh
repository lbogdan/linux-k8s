#!/bin/bash

set -euo pipefail

mkdir -v /var/db/repos/gentoo
env-update
# shellcheck source=/dev/null
source /etc/profile

mkdir -pv /etc/portage/repos.conf
cp -v /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
emerge-webrsync
eselect news read
emerge --sync
printf '\nMAKE_OPTS="-j%s"\n' "$(nproc)" >>/etc/portage/make.conf
emerge --update --deep --newuse --tree @world
emerge --depclean
emerge --tree gentoolkit eix
eix-update
mkdir -p /etc/portage/package.license
echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >/etc/portage/package.license/linux-firmware
emerge --tree genkernel
eselect news read
echo "sys-kernel/gentoo-kernel-bin -initramfs" >/etc/portage/package.use/gentoo-kernel-bin
emerge --tree gentoo-kernel-bin
genkernel initramfs
unlink /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime
printf 'en_US ISO-8859-1\nen_US.UTF-8 UTF-8\n' >>/etc/locale.gen
locale-gen
eselect locale set en_US.utf8
# shellcheck source=/dev/null
env-update && source /etc/profile
echo "sys-boot/grub -fonts -themes" >/etc/portage/package.use/grub
emerge --tree grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
emerge --tree dhcpcd
systemd-machine-id-setup
systemctl preset-all
systemctl enable dhcpcd
echo gentoo-install >/etc/hostname
echo "app-misc/mc -slang" >/etc/portage/package.use/mc
emerge --tree app-misc/mc
eselect news read
printf 'LABEL=boot\t\t/boot\t\text4\t\tnoauto,noatime\t1 2\n' >>/etc/fstab
printf 'UUID=%s\t\t/\t\text4\t\tnoatime\t0 1\n' "$(blkid -o value /dev/sda3 | head -1)" >>/etc/fstab
passwd
systemctl enable sshd
mkdir /root/.ssh
chmod 0600 /root/.ssh
wget -O /root/.ssh/authorized_keys https://github.com/lbogdan.keys
chmod 0400 /root/.ssh/authorized_keys
