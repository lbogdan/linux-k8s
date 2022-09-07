#!/bin/bash

set -euo pipefail

INSTALL_DEVICE=/dev/vda
INSTALL_FOLDER=/mnt/gentoo
# STAGE3_URL=https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220821T170533Z/stage3-amd64-systemd-20220821T170533Z.tar.xz
STAGE3_URL="https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220828T170542Z/stage3-amd64-nomultilib-systemd-20220828T170542Z.tar.xz"

_partition_device() {
  local device="$1"
  parted -a optimal "$device" <<EOT
mklabel gpt
unit MB
mkpart "grub" ext4 1 3
set 1 bios_grub on
mkpart "boot" ext4 3 103
set 2 boot on
mkpart "root" ext4 103 -1
p
q
EOT
}

_mount_partitions() {
  local device="$1"
  local folder="$2"
  mkdir -p "$folder"
  mount "${device}3" "$folder"
  # mount "${device}1" "$folder/boot"
  if [ ! -f /tmp/stage3.tar.xz ]; then
    wget -O /tmp/stage3.tar.xz $STAGE3_URL
  fi
  tar xpvf /tmp/stage3.tar.xz --xattrs-include='*.*' --numeric-owner -C "$folder"
  # unlink /tmp/stage3.tar.xz
  mount "${device}2" "$folder/boot"
  mount --types proc /proc "$folder/proc"
  mount --rbind /sys "$folder/sys"
  mount --make-rslave "$folder/sys"
  mount --rbind /dev "$folder/dev"
  mount --make-rslave "$folder/dev"
  mount --bind /run "$folder/run"
  mount --make-slave "$folder/run"
}

_umount_partitions() {
  local folder="$1"
  umount -l "$folder"/dev{/shm,/pts,}
  umount -R "$folder"
}

_partition_device "$INSTALL_DEVICE"

mkfs.ext4 -F -L boot "${INSTALL_DEVICE}2"
mkfs.btrfs -f "${INSTALL_DEVICE}3"

_mount_partitions "$INSTALL_DEVICE" "$INSTALL_FOLDER"

cp --dereference -v /etc/resolv.conf "$INSTALL_FOLDER/etc"
cp -v ./*.sh $INSTALL_FOLDER

# _umount_partitions "$INSTALL_FOLDER"
