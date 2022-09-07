printf '\nMAKE_OPTS="-j%s"\n' "$(nproc)" >>/etc/portage/make.conf

# mkdir -p /etc/portage/package.license
# echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >/etc/portage/package.license/linux-firmware

echo 'dev-vcs/git -perl' >/etc/portage/package.use/git
echo 'sys-kernel/genkernel -firmware' >/etc/portage/package.use/genkernel

emerge -abtv gentoolkit eix genkernel grub app-misc/mc bash-completion lsof strace btrfs-progs snapper dev-vcs/git chrony ncdu
