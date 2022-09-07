#!/bin/bash

set -euo pipefail

ROOT_FS="btrfs"
KUBERNETES_VERSION="1.23"
CRIO_VERSION="1.25"
RUNC_VERSION="1.1.4"

_setup_packages () {
  printf '\nMAKE_OPTS="-j%s"\nUSE="apparmor"\n' "$(nproc)" >>/etc/portage/make.conf

  # rebuild packages using apparmor
  echo 'sys-libs/libapparmor -perl -python' >/etc/portage/package.use/libapparmor
  # emerge --ask --verbose --deep --tree --newuse -b @world

  # mkdir -p /etc/portage/package.license
  # echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >/etc/portage/package.license/linux-firmware

  echo 'dev-vcs/git -perl' >/etc/portage/package.use/git
  echo 'sys-kernel/genkernel -firmware' >/etc/portage/package.use/genkernel
  echo "sys-boot/grub -fonts -themes" >/etc/portage/package.use/grub
  echo "app-misc/mc -slang" >/etc/portage/package.use/mc

  emerge -abtv gentoolkit eix genkernel grub app-misc/mc bash-completion lsof strace btrfs-progs snapper dev-vcs/git chrony ncdu ebtables ethtool ipvsadm apparmor
  emerge --noreplace nano
  emerge --ask --depclean
}

_setup_system () {
  # timezone
  ln -frsv /usr/share/zoneinfo/UTC /etc/localtime

  # locales
  printf 'en_US ISO-8859-1\nen_US.UTF-8 UTF-8\n' >>/etc/locale.gen
  locale-gen
  eselect locale set en_US.utf8

  # shellcheck source=/dev/null
  env-update && source /etc/profile

  # systemd
  systemd-machine-id-setup
  systemctl preset-all
  # machine id will be auto-generated at first boot
  rm -v /etc/machine-id
  touch /etc/machine-id
  # services
  systemctl enable sshd
  systemctl enable chronyd
  # network
  cat >/etc/systemd/network/10-ethernet.network <<EOT
[Match]
Name=en*
Name=eth*

[Network]
DHCP=ipv4
IPv6AcceptRA=no
LinkLocalAddressing=no

[DHCP]
UseHostname=no
EOT
  # disable systemd-timesyncd as we use chronyd
  systemctl disable systemd-timesyncd
  # resolv.conf
  ln -frsv /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

  # grub
  grub-install /dev/vda
  grub-mkconfig -o /boot/grub/grub.cfg

  # hostname
  echo gentoo-vm-k8s-build-2 >/etc/hostname

  # fstab
  printf 'LABEL=boot\t\t/boot\t\text4\t\tnoauto,noatime\t1 2\n' >>/etc/fstab
  printf 'UUID=%s\t\t/\t\t%s\t\tnoatime\t0 1\n' "$(blkid -o value /dev/vda3 | head -1)" "$ROOT_FS" >>/etc/fstab

  # ssh
  mkdir /root/.ssh
  chmod 0600 /root/.ssh
  wget -O /root/.ssh/authorized_keys https://github.com/lbogdan.keys
  chmod 0400 /root/.ssh/authorized_keys
}

_setup_kubernetes () {
  cat >/etc/portage/repos.conf/linux-k8s.conf <<EOT
[linux-k8s]
location = /var/db/repos/linux-k8s
sync-type = git
sync-uri = https://github.com/lbogdan/linux-k8s-gentoo.git
priority = 100
EOT
  eix-sync

  mkdir -pv /etc/portage/package.accept_keywords
  mkdir -pv /etc/portage/package.mask

  echo 'app-containers/cri-o ~amd64' >/etc/portage/package.accept_keywords/cri-o
  echo ">app-containers/cri-o-$CRIO_VERSION.9999" >/etc/portage/package.mask/cri-o

  echo 'app-containers/cri-tools ~amd64' >/etc/portage/package.accept_keywords/cri-tools

  echo 'app-containers/runc ~amd64' >/etc/portage/package.accept_keywords/runc
  echo ">app-containers/runc-$RUNC_VERSION" >/etc/portage/package.mask/runc

  [ -f /etc/portage/package.accept_keywords/kubernetes ] && unlink /etc/portage/package.accept_keywords/kubernetes
  [ -f /etc/portage/package.mask/kubernetes ] && unlink /etc/portage/package.mask/kubernetes
  for p in kubeadm kubelet kubectl; do
    echo "sys-cluster/$p ~amd64" >>/etc/portage/package.accept_keywords/kubernetes
    echo ">sys-cluster/$p-$KUBERNETES_VERSION.9999" >>/etc/portage/package.mask/kubernetes
  done

  emerge --tree cri-o cri-tools kubeadm kubelet kubectl

  # modules
  cat >/etc/modules-load.d/kubernetes.conf <<EOT
br_netfilter
EOT
  # sysctl
  cat >/etc/sysctl.d/kubernetes.conf <<EOT
net.ipv4.ip_forward = 1
EOT

  # change kubelet service default dependency on docker
  sed -i 's|docker|crio|' /lib/systemd/system/kubelet.service
}

# _setup_kubernetes
_setup_system
