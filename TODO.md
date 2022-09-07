- [x] create gentoo repo repository: https://github.com/lbogdan/linux-k8s-gentoo

- [ ] polish `cri-o` 1.25.0 ebuild and create PR in `gentoo/gentoo`

- [ ] stage3 build scripts

- [x] figure out what of the kernel sources we need in order for packages to check kernel configuration (e.g. `net-libs/libnfnetlink`)
answer:
In `/var/db/repos/gentoo/eclass/linux-info.eclass`, `getfilevar` depends on the kernel root source folder `Makefile` to have all its dependencies:
# @FUNCTION: getfilevar
# @USAGE: <variable> <configfile>
# @RETURN: the value of the variable
# @DESCRIPTION:
# It detects the value of the variable defined in the file configfile. This is
# done by including the configfile, and printing the variable with Make.
# It WILL break if your makefile has missing dependencies!
For this, we can create these empty files: scripts/Makefile.extrawarn include/config/auto.conf.cmd arch/Makefile include/config/auto.conf scripts/Makefile.compiler scripts/subarch.include scripts/Kbuild.include

- [ ] check why the kubelet creates 2 CSRs

- [ ] set grub config (timeout, console etc.)

- [ ] systemd apparmor profiles etc.?