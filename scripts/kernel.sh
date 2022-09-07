#!/bin/bash

set -euo pipefail

KERNEL_VERSION="5.15.59"
CWD="$(pwd)"

cd / && tar -cvzf "$CWD/gentoo-kernel-$KERNEL_VERSION.tar.gz" "/boot/System.map-$KERNEL_VERSION-gentoo-x86_64" "/boot/vmlinuz-$KERNEL_VERSION-gentoo-x86_64" "/lib/modules/$KERNEL_VERSION-gentoo-x86_64" "/usr/src/linux-$KERNEL_VERSION-gentoo/Makefile" "/usr/src/linux-$KERNEL_VERSION-gentoo/Kconfig" "/usr/src/linux-$KERNEL_VERSION-gentoo/include/config/kernel.release" "/usr/src/linux-$KERNEL_VERSION-gentoo/.config" "/etc/kernels/kernel-config-$KERNEL_VERSION-gentoo-x86_64"
