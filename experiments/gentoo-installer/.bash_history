mkdir -v /var/db/repos/gentoo
env-update
# shellcheck source=/dev/null
source /etc/profile
mkdir -pv /etc/portage/repos.conf
cp -v /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
emerge-webrsync
eselect news read
emerge --sync
emerge --update --deep --newuse --tree --ask @world
emerge --ask --depclean
emerge -atv gentoo-kernel-bin
USE="-initramfs" emerge -atv gentoo-kernel-bin
emerge -atv genkernel
printf '\nMAKE_OPTS="-j%s"\n' "$(nproc)" >>/etc/portage/make.conf
env-update 
source /etc/profile
mkdir -p /etc/portage/package.license
echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >/etc/portage/package.license/linux-firmware
emerge -atv lsof strace
emerge -atv gentoolkit eix genkernel grub app-misc/mc bash-completion lsof strace btrfs-progs snapper dev-vcs/git
echo 'dev-vcs/git -perl' >/etc/portage/package.use/git
emerge -atv gentoolkit eix genkernel grub app-misc/mc bash-completion lsof strace btrfs-progs snapper dev-vcs/git
rm -fr /etc/portage/package.license
echo 'sys-kernel/genkernel -firmware' >/etc/portage/package.use/genkernel
emerge -atv gentoolkit eix genkernel grub app-misc/mc bash-completion lsof strace btrfs-progs snapper dev-vcs/git
man emerge
emerge -abtv gentoolkit eix genkernel grub app-misc/mc bash-completion lsof strace btrfs-progs snapper dev-vcs/git
emerge -abtv gentoolkit eix genkernel grub app-misc/mc bash-completion lsof strace btrfs-progs snapper dev-vcs/git chrony
ssh-add -l
eselect news read
ls -al
tar xzvf gentoo-kernel-5.15.59.tar.gz 
eselect kernel list
eselect kernel use 1
eselect kernel set 1
genkernel initramfs
ls -al /boto
ls -al /boot
ls -al
rm gentoo-kernel-5.15.59.tar.gz 
ncdu
emerge -tv ncdu
emerge -btv ncdu
ncdu --color dark -x /
du -sh /
ping
host
emerge -atv host
emerge -atv host-utils
emerge -atv bind-tools
echo "sys-boot/grub -fonts -themes" >/etc/portage/package.use/grub
emerge -atv grub
emerge -abtv grub
emerge --ask --depclean
emerge --noreplace nano
emerge --ask --depclean
emerge -abtv grub
echo "app-misc/mc -slang" >/etc/portage/package.use/mc
emerge -abtv app-misc/mc
equery f chrony
equery f chrony | grep service
bash gentoo-installer-chroot.sh 
eix kubeadm
eix crio
eix cri-o
eix runc
eix -e runc
emerge -atv cri-o
  mkdir -pv /etc/portage/package.accept_keywords
  echo 'app-containers/cri-o ~amd64' >/etc/portage/package.accept_keywords/cri-o
  mkdir -pv /etc/portage/package.accept_keywords
claer
clear
emerge -atv cri-o
echo 'app-containers/runc ~amd64' >/etc/portage/package.accept_keywords/runc
ls -al /var/db/repos/gentoo/app-containers/runc/
ls -al /var/db/repos/gentoo/app-containers/cri-o/
find /var/db/repos/gentoo -name '*999*'
emerge -atv cri-o
ls -al /etc/portage/
echo ">=app-containers/cri-o-$CRIO_VERSION.9999" >/etc/portage/package.mask/cri-o
mkdir -pv /etc/portage/package.mask
echo ">=app-containers/cri-o-$CRIO_VERSION.9999" >/etc/portage/package.mask/cri-o
CRIO_VERSION=1.25
echo ">=app-containers/cri-o-$CRIO_VERSION.9999" >/etc/portage/package.mask/cri-o
emerge -atv cri-o
RUNC_VERSION=1.1.3
echo ">=app-containers/runc-$RUNC_VERSION" >/etc/portage/package.mask/runc
emerge -atv cri-o
cat /etc/portage/package.mask/runc
echo ">app-containers/cri-o-$CRIO_VERSION.9999" >/etc/portage/package.mask/cri-o
echo ">app-containers/runc-$RUNC_VERSION" >/etc/portage/package.mask/runc
emerge -atv cri-o
eix kubelet
  for p in kubeadm kubelet kubectl; do     echo "app-containers/$p ~amd64" >/etc/portage/package.accept_keywords/kubernetes;   done
emerge -atv cri-o kubeadm kubelet kubectl
nano /etc/make.c
nano /etc/portage/make.conf 
emerge -atv cri-o kubeadm kubelet kubectl
emerge --ask --verbose --deep --tree --newuse @world
for p in kubeadm kubelet kubectl; do     echo "app-containers/$p ~amd64" >>/etc/portage/package.accept_keywords/kubernetes;     echo ">app-containers/$p-$KUBERNETES_VERSION.9999" >/etc/portage/package.mask/kubernetes;   done
cat /etc/portage/package.accept_keywords/kubernetes 
[ -f /etc/portage/package.accept_keywords/kubernetes ] && unlink /etc/portage/package.accept_keywords/kubernetes
  [ -f /etc/portage/package.mask/kubernetes ] && unlink /etc/portage/package.mask/kubernetes
  for p in kubeadm kubelet kubectl; do     echo "app-containers/$p ~amd64" >>/etc/portage/package.accept_keywords/kubernetes;     echo ">app-containers/$p-$KUBERNETES_VERSION.9999" >/etc/portage/package.mask/kubernetes;   done
cat /etc/portage/package.accept_keywords/kubernetes 
cat /etc/portage/package.mask/kubernetes 
emerge -atv cri-o kubeadm kubelet kubectl
eix crictl

[ -f /etc/portage/package.accept_keywords/kubernetes ] && unlink /etc/portage/package.accept_keywords/kubernetes
  [ -f /etc/portage/package.mask/kubernetes ] && unlink /etc/portage/package.mask/kubernetes
  for p in kubeadm kubelet kubectl; do     echo "app-containers/$p ~amd64" >>/etc/portage/package.accept_keywords/kubernetes;     echo ">app-containers/$p-$KUBERNETES_VERSION.9999" >/etc/portage/package.mask/kubernetes;   done
eix crictl
eix cri-tools
echo 'app-containers/cri-tools ~amd64' >/etc/portage/package.accept_keywords/cri-tools
emerge -atv cri-o kubeadm kubelet kubectl
emerge -atv cri-o kubeadm kubelet kubectl cri-tools
emerge -abtv ebtables ethtool ipvsadm
emerge --ask --verbose --deep --tree --newuse -b @world
eix -e swig
USE="-perl -python" emerge --ask --verbose --deep --tree --newuse -b @world
echo 'sys-libs/libapparmor -perl -python' >/etc/portake/package.use/libapparmor
echo 'sys-libs/libapparmor -perl -python' >/etc/portage/package.use/libapparmor
emerge --ask --verbose --deep --tree --newuse -b @world
emerge -abtv cri-o cri-tools kubeadm kubelet kubectl
cat /etc/portage/package.mask/kubernetes 
[ -f /etc/portage/package.accept_keywords/kubernetes ] && unlink /etc/portage/package.accept_keywords/kubernetes
  [ -f /etc/portage/package.mask/kubernetes ] && unlink /etc/portage/package.mask/kubernetes
  for p in kubeadm kubelet kubectl; do     echo "sys-cluster/$p ~amd64" >>/etc/portage/package.accept_keywords/kubernetes;     echo ">sys-cluster/$p-$KUBERNETES_VERSION.9999" >/etc/portage/package.mask/kubernetes;   done
  [ -f /etc/portage/package.mask/kubernetes ] && unlink /etc/portage/package.mask/kubernetes
[ -f /etc/portage/package.accept_keywords/kubernetes ] && unlink /etc/portage/package.accept_keywords/kubernetes
  [ -f /etc/portage/package.mask/kubernetes ] && unlink /etc/portage/package.mask/kubernetes
  for p in kubeadm kubelet kubectl; do     echo "sys-cluster/$p ~amd64" >>/etc/portage/package.accept_keywords/kubernetes;     echo ">sys-cluster/$p-$KUBERNETES_VERSION.9999" >/etc/portage/package.mask/kubernetes;   done
emerge -abtv cri-o cri-tools kubeadm kubelet kubectl
[ -f /etc/portage/package.accept_keywords/kubernetes ] && unlink /etc/portage/package.accept_keywords/kubernetes
  [ -f /etc/portage/package.mask/kubernetes ] && unlink /etc/portage/package.mask/kubernetes
  for p in kubeadm kubelet kubectl; do     echo "sys-cluster/$p ~amd64" >>/etc/portage/package.accept_keywords/kubernetes;     echo ">sys-cluster/$p-$KUBERNETES_VERSION.9999" >>/etc/portage/package.mask/kubernetes;   done
emerge -abtv cri-o cri-tools kubeadm kubelet kubectl
nano /etc/portage/package.mask/runc 
emerge -abtv cri-o cri-tools kubeadm kubelet kubectl
kubectl version --client
ncdu -x /
emerge --ask --depclean
ncdu -x /
cat >/etc/modules-load.d/kubernetes.conf <<EOT
br_netfilter
EOT

  cat >/etc/sysctl.d/kubernetes.conf <<EOT
net.ipv4.ip_forward = 1
EOT

ls -al
bash gentoo-installer-chroot.sh 
equery f kubelet
cat /lib/systemd/system/kubelet.service
sed -i 's|docker|crio|' /lib/systemd/system/kubelet.service
cat /lib/systemd/system/kubelet.service
