#!/bin/bash

set -euo pipefail

cat >/etc/portage/repos.conf/linux-k8s.conf <<EOT
[linux-k8s]
location = /var/db/repos/linux-k8s
sync-type = git
sync-uri = https://github.com/lbogdan/linux-k8s-gentoo.git
priority = 100
EOT

emerge --sync linux-k8s

echo 'app-containers/cri-o ~amd64' >/etc/portage/package.accept_keywords/cri-o
echo 'app-containers/runc ~amd64' >/etc/portage/package.accept_keywords/runc

echo '>=sys-cluster/kubeadm-1.24.0' >/etc/portage/package.mask/kubernetes
echo '>=sys-cluster/kubelet-1.24.0' >>/etc/portage/package.mask/kubernetes
echo '>=sys-cluster/kubectl-1.24.0' >>/etc/portage/package.mask/kubernetes

echo 'sys-cluster/kubeadm ~amd64' >/etc/portage/package.accept_keywords/kubernetes
echo 'sys-cluster/kubelet ~amd64' >>/etc/portage/package.accept_keywords/kubernetes
echo 'sys-cluster/kubectl ~amd64' >>/etc/portage/package.accept_keywords/kubernetes

echo 'app-containers/runc apparmor' >/etc/portage/package.use/runc

echo 'app-containers/cri-tools ~amd64' >/etc/portage/package.accept_keywords/cri-tools

emerge --tree cri-o kubeadm kubelet kubectl cri-tools ebtables ethtool ipvsadm apparmor

cat >/etc/modules-load.d/kubernetes.conf <<EOT
br_netfilter
EOT

cat >/etc/sysctl.d/kubernetes.conf <<EOT
net.ipv4.ip_forward = 1
EOT
