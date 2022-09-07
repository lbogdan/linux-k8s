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
grub-install /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg
emerge --tree dhcpcd
systemd-machine-id-setup
systemctl preset-all
# systemctl enable dhcpcd
echo gentoo-vm-k8s >/etc/hostname
echo "app-misc/mc -slang" >/etc/portage/package.use/mc
emerge --tree app-misc/mc
emerge --noreplace nano
eselect news read
printf 'LABEL=boot\t\t/boot\t\text4\t\tnoauto,noatime\t1 2\n' >>/etc/fstab
printf 'UUID=%s\t\t/\t\text4\t\tnoatime\t0 1\n' "$(blkid -o value /dev/vda3 | head -1)" >>/etc/fstab
passwd
systemctl enable sshd
mkdir /root/.ssh
chmod 0600 /root/.ssh
wget -O /root/.ssh/authorized_keys https://github.com/lbogdan.keys
chmod 0400 /root/.ssh/authorized_keys
emerge --tree btrfs-progs snapper
emerge --tree bash-completion
cat >/etc/systemd/network/10-enp1s0.network <<EOT
[Match]
Name=enp1s0

[Network]
DHCP=ipv4
IPv6AcceptRA=no
LinkLocalAddressing=no

[DHCP]
UseHostname=no
EOT
rm -v /etc/machine-id && touch /etc/machine-id

cat >/etc/snapper/configs/root <<EOT

# subvolume to snapshot
SUBVOLUME="/"

# filesystem type
FSTYPE="btrfs"


# btrfs qgroup for space aware cleanup algorithms
QGROUP=""


# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.5"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"


# users and groups allowed to work with config
ALLOW_USERS=""
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="no"


# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="yes"


# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"


# create hourly snapshots
# TIMELINE_CREATE="yes"
TIMELINE_CREATE="no"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="yes"

# limits for timeline cleanup
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="10"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="10"
TIMELINE_LIMIT_YEARLY="10"


# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

# limits for empty pre-post-pair cleanup
EMPTY_PRE_POST_MIN_AGE="1800"

EOT
cat >/etc/conf.d/snapper <<EOT
## Path: System/Snapper

## Type:        string
## Default:     ""
# List of snapper configurations.
SNAPPER_CONFIGS="root"

EOT

btrfs quota enable /
btrfs subvolume create /.snapshots
mkdir -pv /.snapshots/1
btrfs subvolume snapshot -r / /.snapshots/1/snapshot
# for snapper
cat >/.snapshots/1/info.xml <<EOT
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>$(date +%Y-%m-%d\ %H:%M:%S)</date>
  <description>initial snapshot</description>
  <cleanup>root</cleanup>
</snapshot>
EOT

cat >/etc/portage/repos.conf/linux-k8s.conf <<EOT
[linux-k8s]
location = /var/db/repos/linux-k8s
sync-type = git
sync-uri = https://github.com/lbogdan/linux-k8s-gentoo.git
priority = 100
EOT

echo 'dev-vcs/git -perl' >/etc/portage/package.use/git
emerge --tree dev-vcs/git

# rm /etc/resolv.conf
ln -frsv /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
