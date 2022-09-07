#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
LOG_FILE="exec.log"

_do () {
  local message=$1
  echo -n "[ ] $message "
}

_do_ok () {
  echo -e "\r[${GREEN}✓${NC}"
}

_do_error () {
  echo -e "\r[${RED}✕${NC}"
}

_run () {
  local stdout stderr exit_code message
  stdout="$(mktemp run.XXXXXXXXXX)"
  stderr="$(mktemp run.XXXXXXXXXX)"
  message="$(date +'%Y-%m-%d %H:%M:%S') running command: $*"
  if "$@" >"$stdout" 2>"$stderr"; then
    exit_code=0
  else
    exit_code=$?
  fi
  if [ -n "$LOG_FILE" ]; then
    echo "$message" >>"$LOG_FILE"
    if [ -s "$stdout" ]; then
      echo "stdout:" >>"$LOG_FILE"
      cat "$stdout" >>"$LOG_FILE"
    # else
    #   echo "no stdout"
    fi
    if [ -s "$stderr" ]; then
      echo "stderr:" >>"$LOG_FILE"
      cat "$stderr" >>"$LOG_FILE"
    # else
    #   echo "no stderr"
    fi
    echo "exit code: $exit_code" >>"$LOG_FILE"
  fi
  unlink "$stdout"
  unlink "$stderr"
}

_run_message () {
  local message="$1"
  shift
  _do "$message"
  _run "$@"
  _do_ok
}

# _action_start "some action here"
# sleep 2
# _action_ok
# _action_start "second action"
# sleep 3
# _action_error

# _run ls -al /

# echo "next"

# _run_message "listing files" ls -al

# exit 0

INSTALL_DEVICE=/dev/vda
INSTALL_FOLDER=/mnt/gentoo
ROOT_FS="btrfs"
# STAGE3_URL=https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220821T170533Z/stage3-amd64-systemd-20220821T170533Z.tar.xz
# STAGE3_URL="https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220828T170542Z/stage3-amd64-nomultilib-systemd-20220828T170542Z.tar.xz"
STAGE3_URL="https://linux.lbogdan.ro/stages/stage3-amd64-systemd-20220904.tar.xz"

_partition_device() {
  local device="$1"
  _do "partitioning device $device"
  _run parted -a optimal "$device" <<EOT
mklabel gpt
unit MB
mkpart "grub" ext4 1 3
set 1 bios_grub on
mkpart "boot" ext4 3 103
set 2 boot on
mkpart "root" $ROOT_FS 103 -1
p
q
EOT
  _do_ok
}

_mount_partitions() {
  local device="$1"
  local folder="$2"
  mkdir -p "$folder"
  mount "${device}3" "$folder"
  # mount "${device}1" "$folder/boot"
  if [ ! -f /tmp/stage3.tar.xz ]; then
    _do "downloading stage3 archive"
    _run wget -O /tmp/stage3.tar.xz $STAGE3_URL
    _do_ok
  fi
  _do "extracting stage3 archive"
  _run tar xpvf /tmp/stage3.tar.xz --xattrs-include='*.*' --numeric-owner -C "$folder"
  _do_ok
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

# _partition_device "$INSTALL_DEVICE"

_run mkfs.ext4 -F -L boot "${INSTALL_DEVICE}2"
if [ "$ROOT_FS" = btrfs ]; then
  _run mkfs.btrfs -f "${INSTALL_DEVICE}3"
else
  _run mkfs.ext4 -F "${INSTALL_DEVICE}3"
fi

_mount_partitions "$INSTALL_DEVICE" "$INSTALL_FOLDER"

_run cp --dereference -v /etc/resolv.conf "$INSTALL_FOLDER/etc"
_run cp -v ./*.sh $INSTALL_FOLDER

# _umount_partitions "$INSTALL_FOLDER"
