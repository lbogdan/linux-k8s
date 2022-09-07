# scratch file

- create btrfs filesystem:

```sh
mkfs.btrfs /dev/vda3
```

- show btrfs filesystem info:

```sh
btrfs filesystem show
```

- show btrfs filesystem disk usage:

```sh
btrfs filesystem df /mnt/gentoo
btrfs filesystem usage /
```

- get qemu VM network interfaces; needs qemu-guest-agent running inside the VM:

```sh
virsh qemu-agent-command gentoo-test '{"execute":"guest-network-get-interfaces"}' | jq
```

- create btrfs snapshot

```sh
btrfs subvolume create /home
```

- list btrfs snapshots

```sh
btrfs subvolume list /
```

- create btrfs snapshot

```sh
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
</snapshot>
EOT
```

- enable btrfs quota

```sh
btrfs quota enable /
```

 *   CONFIG_NF_CT_NETLINK_HELPER:        is not set when it should be.
 *   CONFIG_NF_CT_NETLINK_TIMEOUT:       is not set when it should be.

packages: git, cri-o, kubeadm, kubelet, kubectl, cri-tools, ebtables, ethtool, ipvsadm

openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | cut -d ' ' -f 2

genkernel --kernel-config=~/work/repos/lbogdan/linux-k8s/experiments/kernel-config/config-5.15.59-gentoo kernel
find / -mount -newer .config | grep -v '^/usr/src/linux'

what can we cleanup:
/var/cache/binpkgs
/var/cache/distfiles

more tools: bind-tools, tcpdump, screen

partition, format, mount
ssh 192.168.122.1 cat work/repos/lbogdan/linux-k8s/experiments/gentoo-installer/linux-k8s.tar.gz | tar xzvf - --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
mount /sys & co.
chroot
grub-install /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg
update /etc/fstab with vda3 UUID
reboot

disable DNSSEC
issue: the VMs are on the same network as the pod network (--cluster-cidr): 192.168.0.0/16

 * Checking for suitable kernel configuration options ...
 *   CONFIG_DEBUG_INFO:  is not set when it should be.                                                                                                                               [ !! ]
 * Please check to make sure these options are set correctly.
 * Failure to do so may cause unexpected problems.

headers needed for bcc:
/usr/src/linux/include/generated
/usr/src/linux/arch/x86/include/generated

GRUB_TIMEOUT=2
GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200n8"
GRUB_TERMINAL="console serial"

genkernel needs `/etc/kernels/kernel-config-5.15.59-gentoo-x86_64` to detect modules compression, make it a symlink to `/usr/src/linux-5.15.59-gentoo`
